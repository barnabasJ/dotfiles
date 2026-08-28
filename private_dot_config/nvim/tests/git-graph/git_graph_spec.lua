-- The graph picker is only usable because its refs are scoped, so that is what
-- these check: which refs the rule picks, and that the graph git draws from them
-- parses back into rows a picker can select from.

local graph = require("barnabasj.git_graph")

local repo, prev_cwd

---@return string
local function run(...)
	local res = vim.system({ "git", ... }, { cwd = repo, text = true }):wait()
	assert.are.equal(0, res.code, table.concat({ ... }, " ") .. ": " .. (res.stderr or ""))
	return vim.trim(res.stdout or "")
end

local function write_file(path, contents)
	local fd = io.open(path, "w")
	if not fd then
		error("could not open " .. path .. " for writing")
	end
	fd:write(contents)
	fd:close()
end

local function commit(file, message)
	write_file(repo .. "/" .. file, file .. message)
	run("add", "-A")
	run("commit", "-m", message)
end

local function has(list, value)
	return vim.tbl_contains(list, value)
end

describe("git_graph", function()
	before_each(function()
		prev_cwd = vim.uv.cwd()
		repo = vim.fn.tempname()
		vim.fn.mkdir(repo, "p")
		run("init", "-q", "-b", "main")
		run("config", "user.email", "test@example.com")
		run("config", "user.name", "test")
		run("config", "commit.gpgsign", "false")
		commit("root.txt", "root")
		-- One branch with work of its own, one already folded back into trunk, and
		-- a remote-tracking copy of the first that has fallen behind.
		run("checkout", "-q", "-b", "feat/live")
		commit("live.txt", "live work")
		run("update-ref", "refs/remotes/origin/feat/live", run("rev-parse", "HEAD"))
		commit("live2.txt", "more live work")
		run("checkout", "-q", "-b", "feat/merged", "main")
		commit("merged.txt", "merged work")
		run("checkout", "-q", "main")
		run("merge", "--ff-only", "feat/merged")
		run("checkout", "-q", "feat/live")
		vim.cmd.cd(repo)
	end)

	after_each(function()
		vim.cmd.cd(prev_cwd)
		vim.fn.delete(repo, "rf")
	end)

	describe("scope", function()
		it("includes trunk and HEAD so the graph always has an anchor", function()
			local refs = graph.scope(repo)

			assert.is_true(has(refs, "main"))
			assert.is_true(has(refs, "HEAD"))
		end)

		it("keeps branches that still have work of their own", function()
			assert.is_true(has(graph.scope(repo), "feat/live"))
		end)

		it("drops branches trunk has already absorbed", function()
			assert.is_false(has(graph.scope(repo), "feat/merged"))
		end)

		it("pulls in the pushed copy, which is what makes divergence visible", function()
			assert.is_true(has(graph.scope(repo), "origin/feat/live"))
		end)

		it("caps how many branches it draws", function()
			for i = 1, 5 do
				run("checkout", "-q", "-b", "feat/extra" .. i, "main")
				commit("extra" .. i .. ".txt", "extra " .. i)
			end
			run("checkout", "-q", "feat/live")

			-- trunk + HEAD + two branches, and no origin copies for the extras.
			local refs = graph.scope(repo, 2)

			assert.are.equal(4, #refs)
		end)
	end)

	describe("checkout", function()
		local function head()
			return run("branch", "--show-current")
		end

		it("switches to the branch on the chosen row", function()
			run("checkout", "-q", "main")

			assert.is_true(graph.checkout({ branch = "feat/live", commit = "x", cwd = repo }))
			assert.are.equal("feat/live", head())
		end)

		it("moves to the local branch when a remote ref was chosen", function()
			run("checkout", "-q", "main")

			-- Checking out `origin/feat/live` verbatim would detach HEAD, which is
			-- not what picking that row means.
			assert.is_true(graph.checkout({ branch = "origin/feat/live", commit = "x", cwd = repo }))
			assert.are.equal("feat/live", head())
		end)

		it("refuses a row that carries no branch", function()
			run("checkout", "-q", "main")

			assert.is_false(graph.checkout({ commit = run("rev-parse", "HEAD"), cwd = repo }))
			assert.are.equal("main", head())
		end)
	end)

	describe("rows", function()
		it("reads a branch name off each decorated commit", function()
			local by_branch = {}
			for _, row in ipairs(graph.rows(repo, graph.scope(repo))) do
				if row.branch then
					by_branch[row.branch] = row
				end
			end

			assert.is_not_nil(by_branch["feat/live"])
			assert.are.equal("more live work", by_branch["feat/live"].subject)
			assert.is_not_nil(by_branch["origin/feat/live"])
		end)

		it("gives every selectable row a commit to diff against", function()
			for _, row in ipairs(graph.rows(repo, graph.scope(repo))) do
				if not row.connector then
					assert.is_truthy(row.commit:match("^%x+$"))
				end
			end
		end)

		it("keeps connector art as rows that cannot be chosen", function()
			-- feat/live has moved on from its pushed copy, so the two lines fork and
			-- git draws the join.
			local connectors = 0
			for _, row in ipairs(graph.rows(repo, graph.scope(repo))) do
				if row.connector then
					connectors = connectors + 1
					assert.is_nil(row.commit)
				end
			end

			assert.is_true(connectors > 0)
		end)
	end)
end)
