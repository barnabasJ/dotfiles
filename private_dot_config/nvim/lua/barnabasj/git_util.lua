-- Plain git plumbing shared by the stack and graph modules: running git, running
-- a lot of git at once, finding the repo, and working out what trunk is. Nothing
-- in here knows about stacks, PRs, or pickers.

local progress = require("barnabasj.git_progress")

local M = {}

--- Every blocking git call goes through here rather than `vim.system():wait()`.
--- Same wait, but routed through the progress module, which is what lets the
--- spinner keep moving while a slow call is in flight -- and what counts the
--- processes the profile reports.
---@return vim.SystemCompleted
local function run(cmd, opts)
	progress.count()
	local done, result = false, nil
	vim.system(cmd, opts, function(res)
		result, done = res, true
	end)
	progress.wait(function()
		return done
	end)
	return result or { code = -1, stdout = "", stderr = "git: timed out" }
end

---@return string|nil # trimmed stdout, or nil when git exits non-zero
function M.git(cwd, ...)
	local cmd = { "git" }
	for _, arg in ipairs({ ... }) do
		cmd[#cmd + 1] = arg
	end
	local res = run(cmd, { cwd = cwd, text = true })
	if res.code ~= 0 then
		return nil
	end
	return vim.trim(res.stdout or "")
end

--- Run a whole batch of git calls at once, keyed by whatever the caller wants
--- back. A stack is a dozen-odd branches and nearly every fact about one needs
--- its own git call, so issuing them serially is what makes these maps feel
--- slow; fired together the batch costs about as much as its slowest member.
---@param batch table<any, string[]>
---@return table<any, string|nil>
function M.git_all(cwd, batch)
	local pending, out = 0, {}
	for key, args in pairs(batch) do
		pending = pending + 1
		local cmd = { "git" }
		vim.list_extend(cmd, args)
		progress.count()
		vim.system(cmd, { cwd = cwd, text = true }, function(res)
			out[key] = res.code == 0 and vim.trim(res.stdout or "") or nil
			pending = pending - 1
		end)
	end
	progress.wait(function()
		return pending == 0
	end)
	return out
end

--- The same batch, yielding instead of blocking. The picker's finder runs in a
--- fast event context where `vim.system():wait()` is simply not allowed, and
--- yielding is what lets the spinner keep moving while the batch is in flight.
---@async
---@param batch table<any, string[]>
---@return table<any, string|nil>
function M.git_all_async(cwd, batch, async)
	local pending, out = 0, {}
	for key, args in pairs(batch) do
		pending = pending + 1
		local cmd = { "git" }
		vim.list_extend(cmd, args)
		progress.count()
		vim.system(cmd, { cwd = cwd, text = true }, function(res)
			out[key] = res.code == 0 and vim.trim(res.stdout or "") or nil
			pending = pending - 1
		end)
	end
	while pending > 0 do
		async:sleep(20)
	end
	return out
end

--- Read many objects with one git process instead of a `cat-file -p` each.
---
--- The per-object version is what made reading a stacking tool's metadata cost a
--- process per branch in the repo -- 214 of them, 420ms, where this returns the
--- same bytes in 4ms. `--batch` answers in input order, so the results line up
--- with `revs` by position; an object that isn't there leaves its slot nil.
---@param revs string[]
---@return string[] # contents, indexed as `revs` is
function M.cat_file_batch(cwd, revs)
	if #revs == 0 then
		return {}
	end
	-- Deliberately not `text = true`: that rewrites CRLF, and the byte counts in
	-- the batch headers are what the contents are sliced by.
	local res = run({ "git", "cat-file", "--batch" }, { cwd = cwd, stdin = table.concat(revs, "\n") .. "\n" })
	if res.code ~= 0 then
		return {}
	end

	local data, out, pos = res.stdout or "", {}, 1
	for i = 1, #revs do
		local eol = data:find("\n", pos, true)
		if not eol then
			break
		end
		-- Either "<oid> <type> <size>" followed by that many bytes and a newline,
		-- or "<rev> missing", which has no body and leaves out[i] unset.
		local size = data:sub(pos, eol - 1):match("^%S+ %S+ (%d+)$")
		pos = eol + 1
		if size then
			out[i] = data:sub(pos, pos + tonumber(size) - 1)
			pos = pos + tonumber(size) + 1
		end
	end
	return out
end

--- Repo root for the current buffer. Diffview panes are `diffview://` URIs whose
--- dirname is not a real directory, hence the stat before trusting it.
function M.repo_root()
	local name = vim.api.nvim_buf_get_name(0)
	local dir = name ~= "" and vim.fs.dirname(name) or nil
	if not dir or not vim.uv.fs_stat(dir) then
		dir = vim.uv.cwd()
	end
	local root = M.git(dir, "rev-parse", "--show-toplevel")
	return (root and root ~= "") and root or nil
end

--- Pick a runner: batched-and-blocking, or batched-and-yielding when handed an
--- async context. Anything that might run inside a picker's finder needs the
--- second, where a blocking wait is illegal.
---@param async? snacks.picker.Async
---@return fun(batch: table<any, string[]>): table<any, string|nil>
function M.runner(cwd, async)
	return function(batch)
		return async and M.git_all_async(cwd, batch, async) or M.git_all(cwd, batch)
	end
end

--- Returns the trunk branch and, separately, the ref to measure against. They
--- are not the same thing. A local `main` sits wherever you last pulled it --
--- 163 commits behind origin in the repo that turned this up -- and measuring a
--- stack against a stale trunk makes the bottom branch look like it contains all
--- of main's catch-up commits too. `origin/main` is what the PRs are opened
--- against, so that is what the diffs are taken from; the local name is only for
--- checking out.
---
--- Two rounds of batched calls rather than a sequence of single ones, both so it
--- is quick and so it can run under either runner.
---@param async? snacks.picker.Async
---@return string|nil trunk, string|nil ref
function M.detect_trunk(cwd, async)
	local batched = M.runner(cwd, async)
	local names = { "main", "master", "trunk", "develop" }

	local batch = { head = { "symbolic-ref", "--short", "refs/remotes/origin/HEAD" } }
	for _, name in ipairs(names) do
		batch["local:" .. name] = { "rev-parse", "--verify", "--quiet", name }
	end
	local out = batched(batch)

	local trunk ---@type string|nil
	local head = out.head
	if head and head ~= "" then
		trunk = (head:gsub("^origin/", ""))
	else
		for _, name in ipairs(names) do
			if out["local:" .. name] then
				trunk = name
				break
			end
		end
	end
	if not trunk then
		return nil
	end

	local remote = "origin/" .. trunk
	return trunk, batched({ remote = { "rev-parse", "--verify", "--quiet", remote } }).remote and remote or trunk
end

--- Check out a branch and let the editor catch up with what changed underneath
--- it. Reporting the failure here means every caller does not have to.
---@return boolean ok
function M.checkout(cwd, branch)
	local res = run({ "git", "checkout", branch }, { cwd = cwd, text = true })
	if res.code ~= 0 then
		vim.notify(vim.trim(res.stderr or "git checkout failed"), vim.log.levels.ERROR)
		return false
	end
	vim.cmd.checktime()
	vim.notify(("git: on %s"):format(branch))
	return true
end

return M
