---@type LazySpec
return {
	"folke/sidekick.nvim",
	opts = {},
	keys = {
		{
			"<tab>",
			function()
				if not require("sidekick").nes_jump_or_apply() then
					return "<tab>"
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select()
			end,
			desc = "Select CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
		{
			"<leader>ac",
			function()
				require("sidekick.cli").toggle({ name = "claude", focus = true })
			end,
			desc = "Sidekick Toggle Claude",
		},
		{
			"<leader>ax",
			function()
				local file = vim.api.nvim_buf_get_name(0)
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local position = file .. ":" .. row .. ":" .. (col + 1)

				local selection = nil
				if vim.fn.mode():match("[vV\22]") then
					vim.cmd('normal! "zy')
					selection = vim.fn.getreg("z")
				end

				vim.ui.input({ prompt = "Transform: " }, function(input)
					if not input or input == "" then
						return
					end

					local prompt = "File: " .. file .. "\nLine: " .. row .. "\n"
					if selection then
						prompt = prompt .. "\nSelected code:\n```\n" .. selection .. "\n```\n"
					end
					prompt = prompt .. "\n" .. input

					local cmd = {
						"claude",
						"-p",
						"--model",
						"sonnet",
						"--allowedTools",
						"Edit,Read,Write",
					}

					vim.notify("Claude working on:\n" .. prompt, vim.log.levels.INFO)
					vim.system(cmd, { stdin = prompt, cwd = vim.fn.getcwd() }, function(result)
						vim.schedule(function()
							vim.cmd("checktime") -- reload changed buffers
							if result.code == 0 then
								vim.notify("Claude: " .. (result.stdout or "done"), vim.log.levels.INFO)
							else
								vim.notify("Claude failed: " .. (result.stderr or result.stdout or ""), vim.log.levels.ERROR)
							end
						end)
					end)
				end)
			end,
			mode = { "n", "x" },
			desc = "Claude Background Transform",
		},
		{
			"<leader>ai",
			function()
				local cli = require("sidekick.cli")
				local Context = require("sidekick.cli.context")
				local Text = require("sidekick.text")
				-- Render placeholders ONCE while still in visual mode so
				-- `{selection}` can read '<,'> marks. Then send via `text`
				-- to skip cli.send's render pass — otherwise braces inside
				-- the selected code (e.g. `{ ... }`) would be re-interpreted
				-- as `%b{}` placeholders, fail lookup, and the whole message
				-- gets dropped with "Nothing to send".
				local in_visual = vim.fn.mode():match("[vV\22]") ~= nil
				local template = in_visual and "{position}\n\n{selection}" or "{position}"
				local rendered = Context.get():render({ msg = template }) or ""
				if in_visual then
					vim.cmd("normal! \27")
				end
				vim.ui.input({ prompt = "Ask: " }, function(input)
					if not input or input == "" then
						return
					end
					local final = rendered .. "\n\n" .. input
					cli.send({ text = Text.to_text(final), submit = true })
				end)
			end,
			mode = { "n", "x" },
			desc = "Sidekick Ask with Context",
		},
	},
}
