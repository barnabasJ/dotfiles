-- The progress module is what the git maps report through, so what these check
-- is the bookkeeping the report is built from: that a run measures the phases it
-- was told about, that a nested run joins the one already in flight rather than
-- starting a second timeline, and that waiting still ends when the thing being
-- waited for is done.

local progress = require("barnabasj.git_progress")

--- Phase labels of the last run, in order.
local function labels()
	return vim.tbl_map(function(p)
		return p.label
	end, progress.last.phases)
end

describe("git_progress", function()
	it("measures each phase it is told about", function()
		progress.run("test", function(run)
			run:phase("first")
			vim.wait(20)
			run:phase("second")
		end)

		assert.are.same({ "first", "second" }, labels())
		for _, p in ipairs(progress.last.phases) do
			assert.is_truthy(p.ms)
		end
		assert.is_true(progress.last.ms >= progress.last.phases[1].ms)
	end)

	it("counts the git processes a phase spawned", function()
		progress.run("test", function(run)
			run:phase("spawning")
			require("barnabasj.git_util").git(vim.uv.cwd(), "--version")
		end)

		assert.are.equal(1, progress.last.phases[1].calls)
		assert.are.equal(1, progress.last.calls)
	end)

	it("folds a nested run into the one already in flight", function()
		local inner_run
		progress.run("outer", function(run)
			run:phase("outer work")
			progress.run("inner", function(nested)
				inner_run = nested
				nested:phase("inner work")
			end)
		end)

		assert.are.equal("outer", progress.last.title)
		assert.are.equal(progress.last, inner_run)
		assert.are.same({ "outer work", "inner work" }, labels())
	end)

	it("hands back what the run returned, and lets an error through", function()
		assert.are.equal(
			"done",
			progress.run("test", function()
				return "done"
			end)
		)

		assert.has_error(function()
			progress.run("test", function()
				error("boom")
			end)
		end)
	end)

	it("stops waiting as soon as the condition holds", function()
		local done = false
		vim.defer_fn(function()
			done = true
		end, 30)

		local t0 = vim.uv.hrtime()
		progress.run("test", function(run)
			run:phase("waiting")
			progress.wait(function()
				return done
			end, 5000)
		end)

		assert.is_true(done)
		-- Nowhere near the timeout: it came back on the condition, not on the clock.
		assert.is_true((vim.uv.hrtime() - t0) / 1e6 < 2000)
	end)

	it("reports the last run without being in one", function()
		progress.run("test", function(run)
			run:phase("something")
		end)
		-- Only that it renders: what it says is a message, not an interface.
		progress.report()
	end)
end)
