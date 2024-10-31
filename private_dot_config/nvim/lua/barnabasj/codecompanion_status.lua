local M = {}

-- Variables to track processing state and spinner index
M.processing = false
M.spinner_index = 1
M.timer = nil

-- Spinner symbols to show processing state
local spinner_symbols = {
	"⠋",
	"⠙",
	"⠹",
	"⠸",
	"⠼",
	"⠴",
	"⠦",
	"⠧",
	"⠇",
	"⠏",
}
local spinner_symbols_len = #spinner_symbols

-- Initializer function to set up autocommands
function M.setup()
	-- Create an autocommand group for CodeCompanion hooks
	local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

	-- Create autocommands to update processing state based on CodeCompanion events
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequest*",
		group = group,
		callback = function(request)
			if request.match == "CodeCompanionRequestStarted" then
				M.processing = true
			elseif request.match == "CodeCompanionRequestFinished" then
				M.processing = false
			end
		end,
	})
end

-- Function to get the current status for the statusline
function M.get_status()
	if M.processing then
		-- Update spinner index and return the current spinner symbol
		if not M.timer then
			M.timer = vim.uv.new_timer()
			M.timer:start(
				100,
				100,
				vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end)
			)
		end
		M.spinner_index = (M.spinner_index % spinner_symbols_len) + 1
		return spinner_symbols[M.spinner_index]
	else
		if M.timer then
			M.timer:stop()
			M.timer:close()
			M.timer = nil
		end
		-- Return an empty string if not processing
		return ""
	end
end

return M
