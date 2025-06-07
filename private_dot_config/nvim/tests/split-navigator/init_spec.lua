local split_navigator = require("split-navigator")

describe("split-navigator", function()
	before_each(function()
		vim.cmd("only") -- Close all splits
		-- Setup with test configuration
		split_navigator.setup({
			overlay = {
				highlight = { fg = "#ffffff", bg = "#ff0000", bold = true },
				border = "single",
				timeout = 1000,
			},
			max_windows = 5,
		})
	end)

	after_each(function()
		vim.cmd("only") -- Clean up splits
	end)

	describe("setup", function()
		it("should create SplitNavigator command", function()
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.SplitNavigator)
		end)
	end)

	describe("show with single window", function()
		it("should show info message for single window", function()
			local messages = {}
			-- Mock vim.notify to capture messages
			local original_notify = vim.notify
			vim.notify = function(msg, level)
				table.insert(messages, { msg = msg, level = level })
			end

			split_navigator.show()

			-- Restore original notify
			vim.notify = original_notify

			assert.equals(1, #messages)
			assert.equals("Only one window open", messages[1].msg)
			assert.equals(vim.log.levels.INFO, messages[1].level)
		end)
	end)

	describe("show with multiple windows", function()
		it("should handle multiple splits", function()
			-- Create splits
			vim.cmd("vsplit")
			vim.cmd("split")

			local utils = require("split-navigator.utils")
			local wins = utils.get_visible_windows()

			-- Should have 3 windows now
			assert.is_true(#wins >= 3)
		end)
	end)
end)

