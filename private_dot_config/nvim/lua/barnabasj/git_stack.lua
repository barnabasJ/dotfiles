-- Stack-aware git helpers.
--
-- A "stack" is a chain of branches where each one is based on the one below it
-- and the bottom one is based on trunk. Working with one needs three things:
--
--   * the ORDER of the branches, bottom (closest to trunk) to top,
--   * each branch's BASE COMMIT -- the commit it forked from, which is exactly
--     the change set its PR shows. This is always computed with merge-base
--     against the branch below, never read from a stacking tool's records: see
--     M.get for why those cannot be trusted.
--   * the STACK ROOT -- the trunk commit the bottom branch forked from. This is
--     NOT the tip of origin/main: main keeps moving, so diffing against its tip
--     drags in every unrelated merge landed since the stack started.
--
-- Three sources can supply the ordering, tried in order. All of them read local
-- files, so they are cheap enough to sit in front of a keypress. `gh stack view`
-- is deliberately not one of them: it queries GitHub and took 1.6s in the repo
-- this was tuned against. It is used only for PR titles and states, in the
-- background, from the picker.
--
--   1. `$GIT_DIR/gh-stack` (github/gh-stack) -- the extension's own state file,
--      carrying the branch order and PR numbers.
--   2. `refs/branch-metadata/<branch>` -- Graphite/Charcoal writes its parent
--      data into a git ref, so older stacks keep working.
--   3. Plain git ancestry -- a branch's parent is the nearest other branch whose
--      tip is contained in its history. Needs no metadata at all, so these maps
--      also work in a repo that never used a stacking tool.
--
-- Every source produces the same table, so the picker, the diffs and the
-- navigation below are written once against that one shape.

local git_util = require("barnabasj.git_util")
local progress = require("barnabasj.git_progress")

local M = {}

local git = git_util.git
local git_all = git_util.git_all
local git_all_async = git_util.git_all_async
local repo_root = git_util.repo_root
local detect_trunk = git_util.detect_trunk

--- PR titles and states are the one thing the state file does not carry, and
--- `gh stack view --json` gets them by querying GitHub -- 1.6s in a big repo, so
--- far too slow to sit in front of a keypress. It runs in the background from
--- the picker instead and folds its answers in when they land.
---@param cb fun(by_name: table<string, table>)
local function gh_pr_details(cwd, cb)
	vim.system({ "gh", "stack", "view", "--json" }, { cwd = cwd, text = true }, function(res)
		if res.code ~= 0 then
			return cb({})
		end
		local ok, data = pcall(vim.json.decode, res.stdout or "")
		if not ok or type(data) ~= "table" or type(data.branches) ~= "table" then
			return cb({})
		end
		local by_name = {}
		for _, e in ipairs(data.branches) do
			if type(e) == "table" and e.name then
				-- The extension is young enough that PR fields may be nested or flat.
				local pr = e.pr or e.pullRequest or {}
				by_name[e.name] = {
					merged = e.isMerged == true or pr.merged == true,
					queued = e.isQueued == true,
					needs_rebase = e.needsRebase == true,
					pr_state = pr.state or e.state,
					pr_draft = pr.draft or e.draft,
					pr_title = pr.title or e.title,
				}
			end
		end
		cb(by_name)
	end)
end

--- gh-stack keeps its whole state in `$GIT_DIR/gh-stack`, so the structure comes
--- from reading that file rather than from `gh stack view`: the file is local and
--- instant where the CLI goes to GitHub. It also covers standing on trunk, which
--- the CLI refuses outright. With several stacks recorded and nothing to pick
--- between them it names them rather than guessing.
---@return table|nil stack, string|nil reason
local function from_gh_stack(cwd, current)
	local dir = git(cwd, "rev-parse", "--absolute-git-dir")
	if not dir then
		return nil
	end
	local fd = io.open(dir .. "/gh-stack", "r")
	if not fd then
		return nil
	end
	local raw = fd:read("*a")
	fd:close()

	local ok, data = pcall(vim.json.decode, raw)
	if not ok or type(data) ~= "table" or type(data.stacks) ~= "table" then
		return nil
	end

	local candidates = {}
	for _, st in ipairs(data.stacks) do
		local trunk = st.trunk and st.trunk.branch or "main"
		local branches = {}
		for _, b in ipairs(st.branches or {}) do
			if b.branch and b.branch ~= trunk then
				local pr = b.pullRequest or b.pr or {}
				branches[#branches + 1] = {
					name = b.branch,
					current = b.branch == current,
					pr_number = pr.number,
					pr_url = pr.url,
				}
			end
		end
		if #branches > 0 then
			candidates[#candidates + 1] = { trunk = trunk, branches = branches, source = "gh-stack" }
		end
	end

	for _, c in ipairs(candidates) do
		for _, b in ipairs(c.branches) do
			if b.current then
				return c
			end
		end
	end
	if #candidates == 1 then
		return candidates[1]
	elseif #candidates > 1 then
		-- Handed back rather than notified here so that callers asking for
		-- silence stay silent; M.get folds it into the one warning it emits.
		local names = {}
		for _, c in ipairs(candidates) do
			names[#names + 1] = c.branches[1].name
		end
		return nil, ("%d stacks recorded, check one out first (%s)"):format(#candidates, table.concat(names, ", "))
	end
	return nil
end

---@return table|nil
local function from_graphite(cwd, current)
	local refs = git(cwd, "for-each-ref", "--format=%(refname:lstrip=2)", "refs/branch-metadata/")
	if not refs or refs == "" then
		return nil
	end

	-- One `cat-file --batch` for the lot. Graphite keeps a metadata ref for every
	-- branch it has ever tracked, so reading them one `cat-file -p` at a time was
	-- a git process per branch in the repo -- 214 processes and 420ms of the
	-- 530ms a stack resolve cost, for data the batch returns in 4ms.
	local names, revs = {}, {}
	for name in vim.gsplit(refs, "\n", { trimempty = true }) do
		names[#names + 1] = name
		revs[#revs + 1] = "refs/branch-metadata/" .. name
	end
	local blobs = git_util.cat_file_batch(cwd, revs)

	local meta, children = {}, {}
	for i, name in ipairs(names) do
		local ok, data = pcall(vim.json.decode, blobs[i] or "")
		if ok and type(data) == "table" then
			meta[name] = data
			local parent = data.parentBranchName
			if parent then
				children[parent] = children[parent] or {}
				table.insert(children[parent], name)
			end
		end
	end

	if not current or current == "" or not meta[current] then
		return nil
	end

	-- Standing on trunk there is no chain to walk up from, but trunk's own record
	-- lists what sits on top of it. One child is a stack to enter; more than one
	-- is a choice this cannot make.
	local entry = current
	if not meta[entry].parentBranchName then
		local kids = children[entry]
		if not kids or #kids ~= 1 then
			return nil
		end
		entry = kids[1]
	end

	-- Downstack is unambiguous: follow parents until one has none, and that last
	-- branch is trunk.
	local chain, seen = { entry }, { [entry] = true }
	local node = entry
	while true do
		local parent = meta[node] and meta[node].parentBranchName
		if not parent or seen[parent] then
			break
		end
		seen[parent] = true
		table.insert(chain, 1, parent)
		node = parent
	end
	local trunk = table.remove(chain, 1)
	if not trunk or #chain == 0 then
		return nil
	end

	-- Upstack can fork. Climb while there is exactly one child and stop at a
	-- branch point rather than silently picking a side.
	node = entry
	while children[node] and #children[node] == 1 and not seen[children[node][1]] do
		node = children[node][1]
		seen[node] = true
		chain[#chain + 1] = node
	end
	local forked = children[node] and #children[node] > 1 or false

	local branches = {}
	for i, name in ipairs(chain) do
		local data = meta[name] or {}
		local pr = data.prInfo or {}
		branches[#branches + 1] = {
			name = name,
			base = data.parentBranchRevision or (i == 1 and trunk or chain[i - 1]),
			current = name == current,
			merged = pr.state == "MERGED",
			pr_number = pr.number,
			pr_title = pr.title,
			pr_state = pr.state,
			pr_draft = pr.draft,
			pr_url = pr.url,
		}
	end
	return { trunk = trunk, branches = branches, source = "graphite", forked = forked }
end

--- The branch tips sitting between `from` and `upto`, nearest to `from` first.
---
--- One topo-ordered walk answers the whole question a chain needs: every branch
--- below `from` is a tip the walk passes through, and the order it passes them
--- in is the order they are stacked. Asking level by level instead -- a
--- `rev-list` to find the next branch down, then another from there -- is the
--- same walk repeated once per level, and it is the round trips that cost.
---
--- Batched over `froms`, because the walks do not depend on each other.
---@param froms string[]
---@return table<string, string[]>
local function branches_between_all(cwd, froms, upto, tips)
	local batch = {}
	for i, from in ipairs(froms) do
		-- Topological, not the default reverse-chronological: committer dates
		-- survive rebases and cherry-picks in whatever order they like, and the
		-- order these are read in *is* the stack order.
		batch[i] = { "rev-list", "--topo-order", from, "^" .. upto }
	end
	local out = git_all(cwd, batch)

	local found = {}
	for i, from in ipairs(froms) do
		local between = {}
		for sha in vim.gsplit(out[i] or "", "\n", { trimempty = true }) do
			for _, name in ipairs(tips[sha] or {}) do
				if name ~= from and name ~= upto then
					between[#between + 1] = name
				end
			end
		end
		found[from] = between
	end
	return found
end

---@return string[]
local function branches_between(cwd, from, upto, tips)
	return branches_between_all(cwd, { from }, upto, tips)[from]
end

---@return table|nil
local function from_git_ancestry(cwd, current)
	if not current or current == "" then
		return nil
	end
	local trunk, trunk_ref = detect_trunk(cwd)
	if not trunk then
		return nil
	end

	local tips = {}
	local refs = git(cwd, "for-each-ref", "--format=%(objectname)\t%(refname:short)", "refs/heads/")
	for line in vim.gsplit(refs or "", "\n", { trimempty = true }) do
		local sha, name = line:match("^(%S+)\t(.+)$")
		if sha then
			tips[sha] = tips[sha] or {}
			table.insert(tips[sha], name)
		end
	end

	-- Standing on trunk, the stack to walk is the one whose bottom forks off it:
	-- the branch with nothing between it and trunk. `--no-merged` cuts a repo full
	-- of stale branches down to the few with work of their own, which is what
	-- keeps the walk per candidate affordable.
	local entry = current
	if current == trunk then
		local open = git(cwd, "branch", "--format=%(refname:short)", "--no-merged", trunk_ref)
		local candidates = vim.split(open or "", "\n", { trimempty = true })
		local below = branches_between_all(cwd, candidates, trunk_ref, tips)
		local bottoms = {}
		for _, name in ipairs(candidates) do
			if #below[name] == 0 then
				bottoms[#bottoms + 1] = name
			end
		end
		if #bottoms ~= 1 then
			return nil
		end
		entry = bottoms[1]
	end

	-- Downstack, in one walk. It comes back nearest-first, so reversing it gives
	-- the bottom-to-top order the rest of this module is written against.
	local below = branches_between(cwd, entry, trunk_ref, tips)
	local chain = {}
	for i = #below, 1, -1 do
		chain[#chain + 1] = below[i]
	end
	chain[#chain + 1] = entry

	-- Upstack. `branch --contains` names everything built on top of the entry in
	-- one call, and one batched walk per candidate says how far up each one sits:
	-- the number of other candidates between it and the entry. Depth 0 is the
	-- direct child, 1 the branch above that, and so on. Two candidates at the same
	-- depth is a branch point, which is where the climb stops rather than silently
	-- picking a side.
	local contains = git(cwd, "branch", "--format=%(refname:short)", "--contains", entry)
	local above = {}
	for name in vim.gsplit(contains or "", "\n", { trimempty = true }) do
		if name ~= entry and name ~= trunk then
			above[#above + 1] = name
		end
	end

	local forked = false
	if #above > 0 then
		local is_above = {}
		for _, name in ipairs(above) do
			is_above[name] = true
		end

		local between = branches_between_all(cwd, above, entry, tips)
		local at_depth = {}
		for _, name in ipairs(above) do
			local depth = 0
			for _, seen in ipairs(between[name]) do
				-- Only other candidates count towards the depth. Anything else the
				-- walk passed is a branch that does not sit on the entry at all.
				if is_above[seen] then
					depth = depth + 1
				end
			end
			at_depth[depth] = at_depth[depth] or {}
			table.insert(at_depth[depth], name)
		end

		local climbed = 0
		for depth = 0, #above - 1 do
			local at = at_depth[depth]
			if not at or #at ~= 1 then
				break
			end
			chain[#chain + 1] = at[1]
			climbed = climbed + 1
		end
		-- Whatever the climb could not take in is a branch point: two branches at
		-- the same height above the entry, which is not a choice this can make.
		forked = climbed < #above
	end

	local branches = {}
	for _, name in ipairs(chain) do
		branches[#branches + 1] = { name = name, current = name == current }
	end
	return { trunk = trunk, branches = branches, source = "git", forked = forked }
end

---@param opts? { notify?: boolean }
---@return table|nil
function M.get(opts)
	opts = opts or {}
	return progress.run("git-stack", function(run)
		run:phase("resolving the stack")
		local cwd = repo_root()
		if not cwd then
			if opts.notify ~= false then
				vim.notify("git-stack: not inside a git repository", vim.log.levels.WARN)
			end
			return nil
		end

		-- Asked once and handed to each source: all three need to know where HEAD
		-- is and none of them can answer it more cheaply than the others.
		local current = git(cwd, "branch", "--show-current")
		local stack, hint = from_gh_stack(cwd, current)
		stack = stack or from_graphite(cwd, current) or from_git_ancestry(cwd, current)
		if not stack then
			if opts.notify ~= false then
				vim.notify("git-stack: " .. (hint or "no stack found for the current branch"), vim.log.levels.WARN)
			end
			return nil
		end
		stack.cwd = cwd

		-- Measure against the remote copy of whatever trunk this stack names, when
		-- there is one. A local `main` sits wherever it was last pulled -- 163
		-- commits behind origin in the repo that turned this up -- and measuring a
		-- stack against a stale trunk makes the bottom branch look like it contains
		-- all of main's catch-up commits too. `origin/<trunk>` is what the PRs are
		-- opened against, so that is what the diffs are taken from.
		--
		-- One rev-parse rather than a full `detect_trunk` round: the source has
		-- already named its trunk, and re-detecting could disagree with it -- a
		-- stack recorded against `develop` would end up measured against
		-- `origin/main`.
		local remote = "origin/" .. stack.trunk
		stack.trunk_ref = git(cwd, "rev-parse", "--verify", "--quiet", remote) and remote or stack.trunk

		-- Recorded bases are discarded here, deliberately. gh-stack stores the SHA a
		-- branch was first created from, so once main moves and the stack is rebased
		-- that SHA is still an *ancestor* of the branch but no longer its fork point
		-- -- which is why running merge-base against the record repairs nothing: the
		-- record is an ancestor, so merge-base hands it straight back. `base..branch`
		-- then sweeps in every main commit in between. On a real 13-branch stack that
		-- turned 10-40 file PR diffs into 1200+ file ones.
		--
		-- The fork point is whatever merge-base says about the branch below, so ask
		-- git about that instead, every time. The whole batch goes out at once.
		run:phase("finding the fork points")
		local batch = {}
		for i, b in ipairs(stack.branches) do
			batch[i] = { "merge-base", i == 1 and stack.trunk_ref or stack.branches[i - 1].name, b.name }
		end
		local bases = git_all(cwd, batch)
		for i, b in ipairs(stack.branches) do
			b.base = bases[i] or b.base
		end
		return stack
	end)
end

---@return integer|nil # index of the branch HEAD is on, nil when off the stack
function M.index(stack)
	for i, b in ipairs(stack.branches) do
		if b.current then
			return i
		end
	end
	return nil
end

--- The trunk commit the bottom branch forked from: the base of the whole stack.
function M.root(stack)
	return stack.branches[1] and stack.branches[1].base
end

local function open(rev_arg)
	progress.run("git-stack", function(run)
		-- Diffview builds the whole view synchronously, so nothing can tick while
		-- it runs: the label is painted going in or it is never seen. It is also
		-- usually the longest phase, which is exactly why it needs saying.
		run:phase("opening the diff", true)
		-- Reopening is the only reliable way to retarget a view that is already up.
		vim.cmd("DiffviewClose")
		-- --imply-local swaps whichever side resolves to HEAD for the working tree,
		-- so that pane stays editable and edits land in the real files (<leader>gR
		-- refreshes). It is a no-op when neither side is HEAD.
		vim.cmd(("DiffviewOpen %s --imply-local"):format(rev_arg))
	end)
end

--- Diff one branch against its own base: exactly what its PR shows.
function M.diff_branch(entry)
	if not entry or not entry.base then
		vim.notify("git-stack: no base recorded for this branch", vim.log.levels.WARN)
		return
	end
	open(("%s...%s"):format(entry.base, entry.name))
end

--- Diff everything from the stack root up to HEAD.
function M.diff_root(stack, head)
	local root = M.root(stack)
	if not root then
		vim.notify("git-stack: could not resolve the stack root", vim.log.levels.WARN)
		return
	end
	open(("%s...%s"):format(root, head or "HEAD"))
end

function M.checkout(stack, branch)
	return progress.run("git-stack", function(run)
		run:phase("checking out " .. branch)
		if not git_util.checkout(stack.cwd, branch) then
			return false
		end

		-- Moving HEAD is the only thing that changed, so the stack in hand is
		-- updated rather than resolved from scratch: the order, the fork points and
		-- the trunk ref are all still the ones just computed. Resolving again here
		-- is what made a step through the stack with a diffview open -- which is
		-- when these maps are actually used -- cost two full resolves instead of
		-- one.
		for _, b in ipairs(stack.branches) do
			b.current = b.name == branch
		end

		-- A diffview left open still points at the branch we just left. Retarget it
		-- so stepping through the stack walks the diffs, not just the checkouts.
		local ok, lib = pcall(require, "diffview.lib")
		if ok and lib.get_current_view() then
			local i = M.index(stack)
			if i then
				M.diff_branch(stack.branches[i])
			end
		end
		return true
	end)
end

--- Step `delta` branches through the stack; +1 is up (away from trunk).
function M.move(delta)
	return progress.run("git-stack", function()
		local stack = M.get()
		if not stack then
			return
		end
		local i = M.index(stack)
		local target
		if not i then
			-- Sitting on trunk or off the stack entirely: "up" enters at the bottom.
			target = delta > 0 and stack.branches[1] and stack.branches[1].name or nil
		elseif i + delta < 1 then
			target = stack.trunk
		elseif i + delta > #stack.branches then
			vim.notify(
				stack.forked and "git-stack: at a branch point -- pick the next branch with the stack picker"
					or "git-stack: already at the top of the stack",
				vim.log.levels.INFO
			)
			return
		else
			target = stack.branches[i + delta].name
		end

		if not target then
			vim.notify("git-stack: nothing to check out", vim.log.levels.INFO)
			return
		end
		M.checkout(stack, target)
	end)
end

--- Go straight to one end of the stack.
---@param where "top"|"bottom"
function M.jump(where)
	return progress.run("git-stack", function()
		local stack = M.get()
		if not stack then
			return
		end
		local target = where == "top" and stack.branches[#stack.branches] or stack.branches[1]
		if not target then
			return
		end
		if target.current then
			vim.notify(("git-stack: already at the %s of the stack"):format(where), vim.log.levels.INFO)
			return
		end
		M.checkout(stack, target.name)
	end)
end

--- "3 hours ago" is too wide for a column; "3h" is not.
local function short_age(rel)
	if not rel or rel == "" then
		return ""
	end
	local n, unit = rel:match("^(%d+)%s+(%a+)")
	if not n then
		return rel
	end
	local units = { second = "s", minute = "m", hour = "h", day = "d", week = "w", month = "mo", year = "y" }
	local suffix = units[(unit:gsub("s$", ""))]
	return suffix and (n .. suffix) or rel
end

--- Fill in the numbers the picker shows: one batch covering every branch's
--- commit count and diffstat plus a for-each-ref for the dates and subjects.
--- Pass an async context to have it yield rather than block.
local function enrich(stack, async)
	local batch = {
		refs = {
			"for-each-ref",
			"--format=%(refname:short)\t%(committerdate:relative)\t%(contents:subject)",
			"refs/heads/",
		},
	}
	for i, b in ipairs(stack.branches) do
		if b.base then
			batch["count:" .. i] = { "rev-list", "--count", b.base .. ".." .. b.name }
			batch["stat:" .. i] = { "diff", "--shortstat", b.base, b.name }
		end
	end
	local out = async and git_all_async(stack.cwd, batch, async) or git_all(stack.cwd, batch)

	local info = {}
	for line in vim.gsplit(out.refs or "", "\n", { trimempty = true }) do
		local name, date, subject = line:match("^([^\t]*)\t([^\t]*)\t(.*)$")
		if name then
			info[name] = { date = date, subject = subject }
		end
	end

	for i, b in ipairs(stack.branches) do
		local meta = info[b.name] or {}
		b.age = short_age(meta.date)
		b.subject = b.pr_title or meta.subject or ""
		b.commits = tonumber(out["count:" .. i]) or 0
		local stat = out["stat:" .. i] or ""
		b.files = tonumber(stat:match("(%d+) file")) or 0
		b.added = tonumber(stat:match("(%d+) insertion")) or 0
		b.removed = tonumber(stat:match("(%d+) deletion")) or 0
	end
end

--- Wait for the background PR lookup without blocking the editor: the picker's
--- spinner only ticks while this task is alive and yielding, so poll rather than
--- sit on a `:wait()`.
---@async
---@return boolean changed
local function await_pr_details(stack, async)
	local answer
	gh_pr_details(stack.cwd, function(by_name)
		answer = by_name
	end)

	local waited = 0
	while not answer and waited < 15000 do
		async:sleep(50)
		waited = waited + 50
	end
	if not answer then
		return false
	end

	local changed = false
	for _, b in ipairs(stack.branches) do
		local pr = answer[b.name]
		if pr then
			b.merged, b.queued, b.needs_rebase = pr.merged, pr.queued, pr.needs_rebase
			b.pr_state = pr.pr_state or b.pr_state
			b.pr_draft = pr.pr_draft or b.pr_draft
			b.pr_title = pr.pr_title or b.pr_title
			b.subject = b.pr_title or b.subject
			changed = true
		end
	end
	return changed
end

--- The leading path segments every branch in the stack shares. Whole stacks tend
--- to sit under one prefix -- an author name, a feature slug -- and repeating it
--- on every row costs the width that tells the branches apart. Only whole
--- segments are dropped, so what is left still starts at a `/` boundary.
---@return string
function M.shared_prefix(branches)
	if #branches < 2 then
		return ""
	end
	local prefix = nil
	for _, b in ipairs(branches) do
		local segments = vim.split(b.name, "/", { plain = true })
		table.remove(segments) -- never eat the part that names the branch
		if not prefix then
			prefix = segments
		else
			local shared = {}
			for i, seg in ipairs(prefix) do
				if segments[i] == seg then
					shared[i] = seg
				else
					break
				end
			end
			prefix = shared
		end
		if #prefix == 0 then
			return ""
		end
	end
	return table.concat(prefix, "/") .. "/"
end

--- Icon and highlight for a branch's PR state. Merged/queued/needs-rebase come
--- straight from gh-stack; the rest is inferred from whether a PR exists at all.
local function pr_icon(b)
	if b.merged then
		return "", "SnacksPickerGitStatusStaged"
	elseif b.queued then
		return "◎", "SnacksPickerGitStatusModified"
	elseif b.needs_rebase then
		return "⚠", "SnacksPickerGitStatusUnmerged"
	elseif b.pr_draft then
		return "○", "SnacksPickerDimmed"
	elseif b.pr_number then
		return "○", "SnacksPickerGitStatusAdded"
	end
	return "·", "SnacksPickerDimmed"
end

local function format(item)
	local a = Snacks.picker.util.align
	local b = item.branch
	local ret = {}

	-- Listed root-first, the way a stack is built: trunk end at the top, newest
	-- work at the bottom. The chain therefore terminates on the last row.
	ret[#ret + 1] = { item.top and "╵ " or "│ ", "SnacksPickerTree" }
	-- Depth up front, so "where am I" is answered without counting rows.
	ret[#ret + 1] = {
		a(tostring(item.position), 3, { align = "right" }),
		b.current and "SnacksPickerGitBranchCurrent" or "SnacksPickerIdx",
	}
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = {
		b.current and "●" or "○",
		b.current and "SnacksPickerGitBranchCurrent" or "SnacksPickerTree",
	}
	ret[#ret + 1] = { " " }
	-- The branch is the stable name for what this step of the stack is for; the
	-- commit subject is whatever the last commit happened to say. Spend the width
	-- on the former.
	ret[#ret + 1] = {
		a(item.short_name, 52, { truncate = true }),
		b.current and "SnacksPickerGitBranchCurrent" or "SnacksPickerGitBranch",
	}

	-- Drafts get no separate column: pr_icon dims the whole PR chunk for them,
	-- which reads as "draft" without spending nine columns saying so.
	local icon, hl = pr_icon(b)
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a(icon .. (b.pr_number and (" #" .. b.pr_number) or ""), 9), hl }

	ret[#ret + 1] = { a((b.commits or 0) .. "c", 4, { align = "right" }), "SnacksPickerGitCommit" }
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a("+" .. (b.added or 0), 6, { align = "right" }), "SnacksPickerGitStatusAdded" }
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a("-" .. (b.removed or 0), 6), "SnacksPickerGitStatusDeleted" }
	ret[#ret + 1] = { a(b.age or "", 5), "SnacksPickerGitDate" }
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a(b.subject or "", 40, { truncate = true }), "SnacksPickerGitMsg" }
	return ret
end

--- The stack as a picker: every branch with its PR, its size and its subject,
--- newest-on-top. <CR> diffs the branch against its own base.
function M.pick()
	local stack = M.get()
	if not stack then
		return
	end

	-- Not enriched here. The finder below does it anyway, with the picker already
	-- on screen and its spinner running; doing it first as well only held the
	-- keypress for a second batch of git nobody ever saw the result of.
	local prefix = M.shared_prefix(stack.branches)

	Snacks.picker({
		-- An async finder rather than a plain item list, for two reasons: the
		-- window opens before any git has run, and snacks ticks its own spinner in
		-- the input line for as long as this task is alive -- which covers the slow
		-- part, the PR lookup that goes to GitHub.
		---@async
		finder = function(_, ctx)
			return function(cb)
				enrich(stack, ctx.async)
				for i, b in ipairs(stack.branches) do
					cb({
						branch = b,
						cwd = stack.cwd,
						position = i,
						total = #stack.branches,
						short_name = prefix ~= "" and b.name:sub(#prefix + 1) or b.name,
						top = i == #stack.branches,
						-- What the fuzzy matcher sees: branch name plus PR number and
						-- title, so "42" or a word from the title both find the row.
						text = table.concat(
							{ b.name, b.pr_number and ("#" .. b.pr_number) or "", b.subject or "" },
							" "
						),
					})
				end
				-- Rows are already on screen by now; this only upgrades them with
				-- merged/queued/draft state and the real PR titles.
				if await_pr_details(stack, ctx.async) then
					ctx.picker.list:update()
				end
			end
		end,
		format = format,
		title = (function()
			local i = M.index(stack)
			-- The prefix is named here because the rows no longer repeat it.
			return ("Stack (%s) — %s · %s of %d%s"):format(
				stack.source,
				stack.trunk,
				i and tostring(i) or "off-stack",
				#stack.branches,
				prefix ~= "" and (" · " .. prefix) or ""
			)
		end)(),
		-- The rows carry a lot of columns, so the list takes the full width and
		-- the preview sits underneath instead of stealing half the screen.
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
				{ win = "preview", title = "{preview}", height = 0.45, border = "top" },
			},
		},
		preview = function(ctx)
			local b = ctx.item.branch
			if not b.base then
				return Snacks.picker.preview.none(ctx)
			end
			Snacks.picker.preview.cmd({
				"git",
				"--no-pager",
				"log",
				"--color=never",
				"--stat",
				"--oneline",
				b.base .. ".." .. b.name,
			}, ctx, { ft = "git" })
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				M.diff_branch(item.branch)
			end
		end,
		actions = {
			stack_checkout = function(picker, item)
				picker:close()
				if item then
					M.checkout(stack, item.branch.name)
				end
			end,
			stack_diff_root = function(picker, item)
				picker:close()
				if item then
					M.diff_root(stack, item.branch.name)
				end
			end,
			stack_open_pr = function(_, item)
				if item and item.branch.pr_url then
					vim.ui.open(item.branch.pr_url)
				else
					vim.notify("git-stack: no PR for this branch", vim.log.levels.INFO)
				end
			end,
		},
		-- <c-r> and <c-g> are spoken for by snacks (insert-register chords and
		-- toggle_live), hence the alt keys for the two extra diffs.
		win = {
			input = {
				keys = {
					["<c-o>"] = { "stack_checkout", mode = { "n", "i" } },
					["<a-b>"] = { "stack_diff_root", mode = { "n", "i" } },
					["<a-o>"] = { "stack_open_pr", mode = { "n", "i" } },
				},
			},
		},
		--- Open on the branch HEAD is actually on, the way the git_branches
		--- picker does, so a tall stack does not start scrolled away from you.
		on_show = function(picker)
			for i, item in ipairs(picker:items()) do
				if item.branch.current then
					picker.list:view(i)
					Snacks.picker.actions.list_scroll_center(picker)
					break
				end
			end
		end,
	})
end

return M
