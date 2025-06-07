local utils = require("split-navigator.utils")

describe("split-navigator utils", function()
	before_each(function()
		vim.cmd("only") -- Close all splits
	end)

	describe("get_visible_windows", function()
		it("should return only normal windows", function()
			local wins = utils.get_visible_windows()
			assert.equals(1, #wins)
		end)

		it("should exclude floating windows", function()
			-- Create a floating window
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_open_win(buf, false, {
				relative = "editor",
				width = 10,
				height = 5,
				row = 5,
				col = 5,
			})

			local wins = utils.get_visible_windows()
			assert.equals(1, #wins) -- Should still be 1 (only the normal window)
		end)
	end)

	describe("get_window_center", function()
		it("should calculate center correctly", function()
			local win = vim.api.nvim_get_current_win()
			local center = utils.get_window_center(win)

			local width = vim.api.nvim_win_get_width(win)
			local height = vim.api.nvim_win_get_height(win)

			assert.equals(math.floor(height / 2), center.row)
			assert.equals(math.floor(width / 2), center.col)
		end)
	end)

	describe("create_overlay_buffer", function()
		it("should create a buffer with content", function()
			local content = " 1 "
			local buf = utils.create_overlay_buffer(content)

			assert.is_true(vim.api.nvim_buf_is_valid(buf))
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			assert.same({ content }, lines)
		end)

		it("should create a non-modifiable buffer", function()
			local buf = utils.create_overlay_buffer(" 1 ")
			local modifiable = vim.api.nvim_buf_get_option(buf, "modifiable")
			assert.is_false(modifiable)
		end)
	end)

	describe("is_valid_window_number", function()
		it("should return true for valid numbers", function()
			assert.is_true(utils.is_valid_window_number("1", 5))
			assert.is_true(utils.is_valid_window_number("3", 5))
			assert.is_true(utils.is_valid_window_number("5", 5))
		end)

		it("should return false for invalid numbers", function()
			assert.is_false(utils.is_valid_window_number("0", 5))
			assert.is_false(utils.is_valid_window_number("6", 5))
			assert.is_false(utils.is_valid_window_number("a", 5))
			assert.is_false(utils.is_valid_window_number("", 5))
		end)
	end)
end)

