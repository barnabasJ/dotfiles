-- `cat_file_batch` is what keeps reading a stacking tool's metadata down to one
-- git process, so what matters is that it hands back the same bytes the
-- per-object reads did: in input order, with the objects that are not there
-- leaving a hole rather than shifting everything after them along.

local git_util = require("barnabasj.git_util")

local repo, prev_cwd

---@return string
local function run(...)
	local res = vim.system({ "git", ... }, { cwd = repo, text = true }):wait()
	assert.are.equal(0, res.code, table.concat({ ... }, " ") .. ": " .. (res.stderr or ""))
	return vim.trim(res.stdout or "")
end

--- Write `contents` into the object database and return the blob's id.
local function blob(contents)
	local res = vim.system({ "git", "hash-object", "-w", "--stdin" }, {
		cwd = repo,
		text = true,
		stdin = contents,
	}):wait()
	assert.are.equal(0, res.code)
	return vim.trim(res.stdout or "")
end

describe("git_util.cat_file_batch", function()
	before_each(function()
		prev_cwd = vim.uv.cwd()
		repo = vim.fn.tempname()
		vim.fn.mkdir(repo, "p")
		run("init", "-q", "-b", "main")
		run("config", "user.email", "test@example.com")
		run("config", "user.name", "test")
		run("config", "commit.gpgsign", "false")
		vim.cmd.cd(repo)
	end)

	after_each(function()
		vim.cmd.cd(prev_cwd)
		vim.fn.delete(repo, "rf")
	end)

	it("reads every object in one pass, in the order it was asked for", function()
		local revs = {}
		for i = 1, 5 do
			revs[i] = blob("contents " .. i)
		end

		local out = git_util.cat_file_batch(repo, revs)
		for i = 1, 5 do
			assert.are.equal("contents " .. i, out[i])
		end
	end)

	it("reads objects whose contents carry newlines", function()
		-- The records are sliced by the byte count in each header rather than split
		-- on newlines, which is the whole reason a blob may contain them.
		local json = '{\n  "parentBranchName": "main"\n}\n'
		local out = git_util.cat_file_batch(repo, { blob(json) })
		assert.are.equal(json, out[1])
	end)

	it("leaves a hole for an object that is not there, without shifting the rest", function()
		local first, last = blob("first"), blob("last")

		local out = git_util.cat_file_batch(repo, { first, "refs/branch-metadata/never-existed", last })
		assert.are.equal("first", out[1])
		assert.is_nil(out[2])
		assert.are.equal("last", out[3])
	end)

	it("asks git nothing at all when there is nothing to read", function()
		assert.are.same({}, git_util.cat_file_batch(repo, {}))
	end)
end)
