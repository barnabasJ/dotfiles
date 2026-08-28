-- The three stack sources all reduce to the same table, so these specs build a
-- throwaway repo and check each one produces it: the branches in bottom-to-top
-- order, each branch's base commit, and the root the whole stack forked from.

local stack = require("barnabasj.git_stack")

local repo, prev_cwd

---@return string
local function run(...)
	local res = vim.system({ "git", ... }, { cwd = repo, text = true }):wait()
	assert.are.equal(0, res.code, table.concat({ ... }, " ") .. ": " .. (res.stderr or ""))
	return vim.trim(res.stdout or "")
end

--- stack.get() is nil-able by design. In a spec a nil is simply a failure, so
--- say so once here rather than nil-checking at every use.
---@return table
local function get_stack()
	local s = stack.get()
	assert.is_truthy(s)
	---@cast s table
	return s
end

--- Not `assert(io.open(...))`: under busted the global `assert` is luassert's
--- table, which is not callable.
local function write_file(path, contents)
	local fd = io.open(path, "w")
	if not fd then
		error("could not open " .. path .. " for writing")
	end
	fd:write(contents)
	fd:close()
end

local function commit(file, message)
	write_file(repo .. "/" .. file, file)
	run("add", "-A")
	run("commit", "-m", message)
end

--- Graphite/Charcoal keep their metadata in a blob under refs/branch-metadata.
local function write_branch_metadata(branch, data)
	local res = vim.system({ "git", "hash-object", "-w", "--stdin" }, {
		cwd = repo,
		text = true,
		stdin = vim.json.encode(data),
	}):wait()
	assert.are.equal(0, res.code)
	run("update-ref", "refs/branch-metadata/" .. branch, vim.trim(res.stdout or ""))
end

--- main -> feat/one -> feat/two -> feat/three, one commit each.
local function build_stack()
	repo = vim.fn.tempname()
	vim.fn.mkdir(repo, "p")
	run("init", "-q", "-b", "main")
	run("config", "user.email", "test@example.com")
	run("config", "user.name", "test")
	-- The real config signs commits; a test repo has no business waiting on gpg.
	run("config", "commit.gpgsign", "false")
	commit("root.txt", "root")
	for _, b in ipairs({ "one", "two", "three" }) do
		run("checkout", "-q", "-b", "feat/" .. b)
		commit(b .. ".txt", b)
	end
	vim.cmd.cd(repo)
end

local function names(s)
	return vim.tbl_map(function(b)
		return b.name
	end, s.branches)
end

describe("git_stack", function()
	before_each(function()
		prev_cwd = vim.uv.cwd()
		build_stack()
	end)

	after_each(function()
		vim.cmd.cd(prev_cwd)
		vim.fn.delete(repo, "rf")
	end)

	describe("plain git ancestry", function()
		it("reconstructs the chain with no stacking metadata at all", function()
			run("checkout", "-q", "feat/two")
			local s = get_stack()

			assert.are.equal("git", s.source)
			assert.are.equal("main", s.trunk)
			assert.are.same({ "feat/one", "feat/two", "feat/three" }, names(s))
			assert.are.equal(2, stack.index(s))
		end)

		it("bases each branch on the one below it", function()
			run("checkout", "-q", "feat/two")
			local s = get_stack()

			for i = 2, #s.branches do
				assert.are.equal(run("rev-parse", s.branches[i - 1].name), s.branches[i].base)
			end
		end)

		it("roots the stack at the trunk commit the bottom branch forked from", function()
			run("checkout", "-q", "feat/three")
			local s = get_stack()

			assert.are.equal(run("rev-parse", "main"), stack.root(s))
		end)

		it("still finds the stack while sitting on trunk", function()
			run("checkout", "-q", "main")
			local s = get_stack()

			assert.are.same({ "feat/one", "feat/two", "feat/three" }, names(s))
			assert.is_nil(stack.index(s))
		end)

		it("reports no stack when trunk has absorbed every branch", function()
			run("checkout", "-q", "main")
			run("merge", "--ff-only", "feat/three")

			assert.is_nil(stack.get({ notify = false }))
		end)
	end)

	describe("graphite metadata", function()
		before_each(function()
			write_branch_metadata("main", { children = { "feat/one" } })
			local parents = { ["feat/one"] = "main", ["feat/two"] = "feat/one", ["feat/three"] = "feat/two" }
			local numbers = { ["feat/one"] = 1, ["feat/two"] = 2, ["feat/three"] = 3 }
			for branch, parent in pairs(parents) do
				write_branch_metadata(branch, {
					parentBranchName = parent,
					parentBranchRevision = run("rev-parse", parent),
					prInfo = { number = numbers[branch], title = branch .. " title", state = "OPEN" },
				})
			end
			run("checkout", "-q", "feat/two")
		end)

		it("is preferred over ancestry and carries PR info", function()
			local s = get_stack()

			assert.are.equal("graphite", s.source)
			assert.are.same({ "feat/one", "feat/two", "feat/three" }, names(s))
			assert.are.equal(2, s.branches[2].pr_number)
			assert.are.equal("feat/two title", s.branches[2].pr_title)
		end)

		it("enters the stack from trunk through the recorded children", function()
			run("checkout", "-q", "main")
			local s = get_stack()

			assert.are.equal("graphite", s.source)
			assert.are.same({ "feat/one", "feat/two", "feat/three" }, names(s))
		end)
	end)

	describe("gh-stack state file", function()
		before_each(function()
			local dir = run("rev-parse", "--absolute-git-dir")
			local branches = {}
			for _, b in ipairs({ "feat/one", "feat/two", "feat/three" }) do
				branches[#branches + 1] = { branch = b, base = run("rev-parse", b .. "^") }
			end
			write_file(
				dir .. "/gh-stack",
				vim.json.encode({
					schemaVersion = 1,
					stacks = { { trunk = { branch = "main" }, branches = branches } },
				})
			)
		end)

		it("is preferred over graphite and ancestry", function()
			run("checkout", "-q", "feat/three")
			local s = get_stack()

			-- Which gh-stack path answers depends on whether the CLI extension is
			-- installed on the machine running the suite -- both read this same
			-- state file, so either is a pass.
			assert.is_truthy(s.source:match("^gh%-stack"))
			assert.are.same({ "feat/one", "feat/two", "feat/three" }, names(s))
			assert.are.equal(3, stack.index(s))
		end)
	end)

	describe("base resolution", function()
		it("takes each base from the fork point rather than a stacking tool's record", function()
			local recorded = run("rev-parse", "main")
			local dir = run("rev-parse", "--absolute-git-dir")
			write_file(
				dir .. "/gh-stack",
				vim.json.encode({
					schemaVersion = 1,
					stacks = {
						{ trunk = { branch = "main" }, branches = { { branch = "feat/one", base = recorded } } },
					},
				})
			)

			-- Main moves on and the branch is rebased onto it, which leaves the
			-- record describing only where the branch started. It stays an
			-- *ancestor* of the branch, so merge-base against the record returns
			-- the record -- the fork point can only come from the branch below.
			run("checkout", "-q", "main")
			commit("moved.txt", "main moves on")
			run("checkout", "-q", "feat/one")
			run("rebase", "main")

			local s = get_stack()
			local base = s.branches[1].base

			assert.are.equal(run("rev-parse", "main"), base)
			assert.are_not.equal(recorded, base)
			assert.are.equal("one.txt", run("diff", "--name-only", base, "feat/one"))
		end)

		it("measures the bottom of the stack against origin/main, not the local trunk", function()
			-- A local `main` sits wherever it was last pulled, so it is the remote
			-- ref that says where the stack forked from. Set up that gap: a commit
			-- only the remote-tracking ref knows about, with the stack rebased onto
			-- it.
			run("checkout", "-q", "main")
			commit("remote-only.txt", "landed on the remote")
			local remote_tip = run("rev-parse", "main")
			run("update-ref", "refs/remotes/origin/main", remote_tip)
			run("reset", "-q", "--hard", "HEAD~1")
			run("checkout", "-q", "feat/one")
			run("rebase", remote_tip)

			local s = get_stack()

			assert.are.equal("origin/main", s.trunk_ref)
			assert.are.equal(remote_tip, s.branches[1].base)
			-- Measured against the local trunk this would also carry remote-only.txt,
			-- which belongs to no branch in the stack.
			assert.are.equal("one.txt", run("diff", "--name-only", s.branches[1].base, "feat/one"))
		end)
	end)

	describe("branch name prefixes", function()
		-- Stacks tend to sit under one prefix, and repeating it on every row costs
		-- the width that actually tells the branches apart.
		local function names_of(...)
			return vim.tbl_map(function(n)
				return { name = n }
			end, { ... })
		end

		it("finds the leading segments every branch shares", function()
			local prefix = stack.shared_prefix(names_of("me/eden-01-a", "me/eden-02-b", "me/eden-03-c"))

			assert.are.equal("me/", prefix)
		end)

		it("keeps whole segments, so what is left starts at a boundary", function()
			-- "feat/" is shared but "eden-0" is only a partial segment match.
			local prefix = stack.shared_prefix(names_of("feat/eden-01", "feat/eden-02"))

			assert.are.equal("feat/", prefix)
		end)

		it("strips nothing when the branches share no prefix", function()
			assert.are.equal("", stack.shared_prefix(names_of("me/one", "you/two")))
		end)

		it("never eats the segment that names the branch", function()
			-- Both sit at "me/eden/", and dropping that last shared segment would
			-- leave two rows both reading "a" and "b".
			local prefix = stack.shared_prefix(names_of("me/eden/a", "me/eden/b"))

			assert.are.equal("me/eden/", prefix)
			assert.are.equal("a", ("me/eden/a"):sub(#prefix + 1))
		end)

		it("strips nothing from a stack of one, having nothing to compare against", function()
			assert.are.equal("", stack.shared_prefix(names_of("me/only")))
		end)

		it("strips nothing when the branches are unprefixed", function()
			assert.are.equal("", stack.shared_prefix(names_of("one", "two")))
		end)
	end)

	describe("diff commands", function()
		local captured

		local real_cmd

		before_each(function()
			run("checkout", "-q", "feat/two")
			captured = {}
			real_cmd = vim.cmd
			-- Capture `vim.cmd("...")` while leaving `vim.cmd.cd()` and friends
			-- working, since the surrounding hooks still need them.
			vim.cmd = setmetatable({}, {
				__call = function(_, c)
					captured[#captured + 1] = c
				end,
				__index = function(_, key)
					return real_cmd[key]
				end,
			})
		end)

		after_each(function()
			vim.cmd = real_cmd
		end)

		it("diffs a branch against its own base, not against trunk's tip", function()
			local s = get_stack()
			stack.diff_branch(s.branches[stack.index(s)])

			assert.are.same({
				"DiffviewClose",
				("DiffviewOpen %s...feat/two --imply-local"):format(run("rev-parse", "feat/one")),
			}, captured)
		end)

		it("diffs the whole stack against the commit it forked from", function()
			local s = get_stack()
			stack.diff_root(s)

			assert.are.same({
				"DiffviewClose",
				("DiffviewOpen %s...HEAD --imply-local"):format(run("rev-parse", "main")),
			}, captured)
		end)
	end)

	describe("navigation", function()
		local function head()
			return run("branch", "--show-current")
		end

		it("walks up to the top and stops there", function()
			run("checkout", "-q", "feat/two")
			stack.move(1)
			assert.are.equal("feat/three", head())
			stack.move(1)
			assert.are.equal("feat/three", head())
		end)

		it("walks down through the bottom onto trunk", function()
			run("checkout", "-q", "feat/two")
			stack.move(-1)
			assert.are.equal("feat/one", head())
			stack.move(-1)
			assert.are.equal("main", head())
		end)

		it("jumps straight to the top of the stack", function()
			run("checkout", "-q", "feat/one")
			stack.jump("top")
			assert.are.equal("feat/three", head())
		end)

		it("jumps straight to the bottom of the stack", function()
			run("checkout", "-q", "feat/three")
			stack.jump("bottom")
			assert.are.equal("feat/one", head())
		end)

		it("jumps into the stack from trunk", function()
			run("checkout", "-q", "main")
			stack.jump("top")
			assert.are.equal("feat/three", head())
		end)

		it("re-enters the stack at the bottom when moving up from trunk", function()
			run("checkout", "-q", "main")
			stack.move(1)
			assert.are.equal("feat/one", head())
		end)
	end)
end)
