-- A branch picker you read as a graph.
--
-- The problem with `git log --graph` in a picker is scale, not rendering: in a
-- monorepo here `--all` draws a 52-column-wide graph and
-- `--branches --remotes --tags` an 88-column one, a third of whose lines carry
-- no commit at all. Neither is something you can pick a branch out of.
--
-- So the refs are scoped, by a rule that is pure git and holds in any repo:
--
--   * trunk, and HEAD,
--   * the most recently updated local branches that are not yet merged into
--     trunk -- the ones you still have work on,
--   * and their `origin/` counterparts, which is what makes "my local branch has
--     moved away from what I pushed" visible as a fork rather than a fact you
--     have to go looking for.
--
-- Measured across repos from a 227-branch monorepo down to single-branch ones,
-- that keeps the graph between 2 and 6 columns wide.
--
-- The cap is a real truncation, so it is never the only way in: <a-a> drops to
-- the plain all-branches picker, which is also on <leader>gb.

local git_util = require("barnabasj.git_util")

local M = {}

--- How many unmerged local branches to draw before the graph stops being worth
--- reading. Twenty covers a working set; the rest are an <a-a> away.
local BRANCH_LIMIT = 20

--- How far back to walk. The graph is for orienting among branches, not for
--- browsing history, so this only has to reach past where they diverge.
local COMMIT_LIMIT = 400

--- The refs the graph is drawn from, most recently touched first.
--- Deliberately one return value: `M.rows(cwd, M.scope(cwd))` would otherwise
--- splice a second one straight into the `async` slot.
---@return string[]
function M.scope(cwd, limit, async)
	local run = git_util.runner(cwd, async)
	local trunk, trunk_ref = git_util.detect_trunk(cwd, async)
	trunk_ref = trunk_ref or trunk or "HEAD"

	-- Both halves are one git call each. Asking per branch instead -- a rev-list
	-- to see if it is merged, a rev-parse to see if it has been pushed -- is 200+
	-- processes in a repo this size and measured 1.7s; for-each-ref does the same
	-- filtering itself in 0.35s.
	local out = run({
		unmerged = {
			"for-each-ref",
			"--sort=-committerdate",
			"--format=%(refname:short)",
			"--no-merged",
			trunk_ref,
			"refs/heads/",
		},
		pushed = { "for-each-ref", "--format=%(refname:short)", "refs/remotes/origin/" },
	})

	local pushed = {}
	for name in vim.gsplit(out.pushed or "", "\n", { trimempty = true }) do
		pushed[name] = true
	end

	local refs = { trunk_ref, "HEAD" }
	local kept = 0
	for name in vim.gsplit(out.unmerged or "", "\n", { trimempty = true }) do
		if kept >= (limit or BRANCH_LIMIT) then
			break
		end
		if name ~= trunk then
			kept = kept + 1
			refs[#refs + 1] = name
			if pushed["origin/" .. name] then
				refs[#refs + 1] = "origin/" .. name
			end
		end
	end
	return refs
end

--- Parse `git log --graph` into rows. The format is NUL-delimited so the graph
--- glyphs, which git prepends and which have no fixed width, can be split off
--- without guessing: everything before the first NUL is the graph. Lines with no
--- NUL at all are pure connector art -- kept, so the graph still reads, but not
--- selectable.
---@return table[]
function M.rows(cwd, refs, async)
	local args = {
		"log",
		"--graph",
		"--format=%x00%h%x00%D%x00%s",
		"-n",
		tostring(COMMIT_LIMIT),
		-- Without this the walk is mostly trunk's own history, which carries no
		-- branch information at all: in one repo it pushed the only real fork down
		-- to row 193, so the first screen looked like a flat list and the graph
		-- appeared to be doing nothing. Keeping only commits that carry one of our
		-- refs, plus the topology joining them, brought that to row 17 and the row
		-- count from 401 to 83.
		"--simplify-by-decoration",
	}
	-- Decoration has to be pinned to the refs in scope, or "carries a ref" also
	-- means every release tag in the repo -- which put dozens of `chore: release`
	-- rows between the branches.
	for _, ref in ipairs(refs) do
		if ref ~= "HEAD" then
			local full = ref:match("^origin/") and ("refs/remotes/" .. ref) or ("refs/heads/" .. ref)
			args[#args + 1] = "--decorate-refs=" .. full
		end
	end
	vim.list_extend(args, refs)
	args[#args + 1] = "--"
	-- Routed through the batch runner purely to pass the args as a table.
	local out = git_util.runner(cwd, async)({ log = args }).log

	local ret = {}
	for line in vim.gsplit(out or "", "\n", { trimempty = false }) do
		local graph, hash, decor, subject = line:match("^(.-)%z(%S*)%z(.-)%z(.*)$")
		if graph then
			local branches = {}
			for ref in vim.gsplit(decor or "", ",", { trimempty = true }) do
				ref = vim.trim(ref)
				-- `%D` writes the current branch as "HEAD -> name"; keep the name.
				ref = ref:gsub("^HEAD %-> ", "")
				if ref ~= "" and ref ~= "HEAD" and not ref:match("^tag: ") then
					branches[#branches + 1] = ref
				end
			end
			ret[#ret + 1] = {
				graph = graph,
				commit = hash,
				branches = branches,
				branch = branches[1],
				subject = subject,
			}
		elseif line:match("%S") then
			ret[#ret + 1] = { graph = line, connector = true }
		end
	end
	return ret
end

local function format(item, picker)
	local a = Snacks.picker.util.align
	local ret = {}

	-- The connector art only lines up while every row is present and in order.
	-- Once a filter is on that is no longer true, so drop the graph column rather
	-- than draw glyphs that connect to nothing.
	local filtering = (picker.input.filter.pattern or "") ~= ""
	if not filtering then
		ret[#ret + 1] = { item.graph, "SnacksPickerTree" }
	end
	if item.connector then
		return ret
	end

	ret[#ret + 1] = { a(item.commit, 9), "SnacksPickerGitCommit" }
	ret[#ret + 1] = { " " }
	for _, name in ipairs(item.branches) do
		local hl = name:match("^origin/") and "SnacksPickerDimmed" or "SnacksPickerGitBranch"
		ret[#ret + 1] = { name, hl }
		ret[#ret + 1] = { " " }
	end
	ret[#ret + 1] = { item.subject or "", "SnacksPickerGitMsg" }
	return ret
end

--- Check out whatever was picked off the graph.
---
--- A row may only carry a remote ref, and checking that out detaches HEAD --
--- almost never what "switch to this branch" meant. When the same branch exists
--- locally, that is the one to move to.
---@param choice { branch?: string, commit: string, cwd: string }
---@return boolean ok
function M.checkout(choice)
	local name = choice.branch
	if not name then
		vim.notify("git-graph: that commit has no branch on it", vim.log.levels.WARN)
		return false
	end
	local tracked = name:match("^origin/(.+)$")
	if tracked and git_util.git(choice.cwd, "rev-parse", "--verify", "--quiet", tracked) then
		name = tracked
	end
	return git_util.checkout(choice.cwd, name)
end

--- Pick a ref off the graph.
---@param opts { title?: string, on_choose: fun(choice: { branch?: string, commit: string }) }
function M.pick(opts)
	local cwd = git_util.repo_root()
	if not cwd then
		vim.notify("git-graph: not inside a git repository", vim.log.levels.WARN)
		return
	end

	Snacks.picker({
		---@async
		finder = function(_, ctx)
			return function(cb)
				local refs = M.scope(cwd, nil, ctx.async)
				for _, row in ipairs(M.rows(cwd, refs, ctx.async)) do
					row.cwd = cwd
					-- Connector rows match nothing, so a filter hides them along with
					-- the graph column they belong to.
					row.text = row.connector and ""
						or table.concat({ row.commit, table.concat(row.branches, " "), row.subject or "" }, " ")
					cb(row)
				end
				ctx.async:sleep(0)
			end
		end,
		format = format,
		title = opts.title or "Git graph",
		layout = {
			layout = {
				backdrop = false,
				width = 0.9,
				min_width = 100,
				height = 0.85,
				box = "vertical",
				border = true,
				title = "{title} {live} {flags}",
				title_pos = "center",
				{ win = "input", height = 1, border = "bottom" },
				{ win = "list", border = "none" },
				{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
			},
		},
		preview = function(ctx)
			if ctx.item.connector then
				return Snacks.picker.preview.none(ctx)
			end
			Snacks.picker.preview.cmd({
				"git",
				"--no-pager",
				"show",
				"--color=never",
				"--stat",
				"--oneline",
				ctx.item.commit,
			}, ctx, { ft = "git" })
		end,
		confirm = function(picker, item)
			if not item or item.connector then
				return
			end
			picker:close()
			opts.on_choose({ branch = item.branch, commit = item.commit, cwd = cwd })
		end,
		actions = {
			graph_checkout = function(picker, item)
				picker:close()
				if item and not item.connector then
					M.checkout({ branch = item.branch, commit = item.commit, cwd = cwd })
				end
			end,
			-- The scope is capped, so there has to be a way past it.
			graph_all_branches = function(picker)
				picker:close()
				Snacks.picker.git_branches({
					confirm = function(p, item)
						p:close()
						if item and item.branch then
							opts.on_choose({ branch = item.branch, commit = item.commit, cwd = cwd })
						end
					end,
				})
			end,
		},
		win = {
			input = {
				keys = {
					["<c-o>"] = { "graph_checkout", mode = { "n", "i" } },
					["<a-a>"] = { "graph_all_branches", mode = { "n", "i" } },
				},
			},
		},
	})
end

return M
