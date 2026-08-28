-- Diffview renders each side of a diff as a `diffview://<repo>/.git/<sha>/<path>`
-- scratch buffer, so sidekick's `{position}` placeholder hands the agent a path
-- it cannot open. Rebuild the location from diffview's own view state instead:
-- the repo-relative path, the rev that pane is showing, and whether it is the
-- editable working-tree side. Returns nil when we're not in a diffview.
local function diffview_location()
	local ok, lib = pcall(require, "diffview.lib")
	if not ok then
		return nil
	end
	-- diffview ships no LuaCATS types, so every field below is opaque to lua_ls.
	---@type any
	local view = lib.get_current_view()
	if not view then
		return nil
	end
	local got_file, file = pcall(view.infer_cur_file, view)
	if not got_file or not file then
		return nil
	end

	local lines = {}
	if view.rev_arg then
		lines[#lines + 1] = ("Reviewing diff `%s` in %s"):format(view.rev_arg, view.adapter.ctx.toplevel)
	end

	local bufname = vim.api.nvim_buf_get_name(0)
	-- The sha is only in the name of a git-object pane; the working-tree side
	-- keeps its real path, and the file panel has neither.
	local rev = bufname:match("/%.git/(%x+)/")
	if rev then
		local row = vim.api.nvim_win_get_cursor(0)[1]
		lines[#lines + 1] = ("File: %s:%d — read-only side of the diff, at rev %s."):format(file.path, row, rev)
		lines[#lines + 1] = ("Read it with `git show %s:%s`; the line number is from that revision."):format(
			rev,
			file.path
		)
	elseif bufname:match("^diffview://") then
		lines[#lines + 1] = ("File: %s — selected in the diffview file panel (status %s)."):format(
			file.path,
			file.status or "?"
		)
	else
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		lines[#lines + 1] = ("File: %s:%d:%d — working-tree side, edit it directly."):format(
			file.absolute_path,
			row,
			col + 1
		)
	end
	return table.concat(lines, "\n")
end

--- Prompt for something to say to the agent.
---
--- `opts.submit` decides what <CR> does. Queueing rather than submitting is what
--- makes a PR review workable: sidekick's `send` writes into the CLI's input
--- buffer and only `submit` sends the carriage return, so notes left unsubmitted
--- stack up as lines in the agent's prompt and all go at once when you finally
--- submit. Either action is always reachable -- whichever one is not on <CR> is
--- on <C-s>.
---
--- `opts.context` prepends where you are: the file and position, the selection,
--- or the diff location. Turn it off for a plain question, where a path and line
--- number would just be noise the agent has to read past.
---@param opts { submit: boolean, context: boolean }
local function ask(opts)
	local cli = require("sidekick.cli")
	local Text = require("sidekick.text")

	local rendered = ""
	if opts.context then
		local Context = require("sidekick.cli.context")
		-- Render placeholders ONCE while still in visual mode so
		-- `{selection}` can read '<,'> marks. Then send via `text`
		-- to skip cli.send's render pass — otherwise braces inside
		-- the selected code (e.g. `{ ... }`) would be re-interpreted
		-- as `%b{}` placeholders, fail lookup, and the whole message
		-- gets dropped with "Nothing to send".
		local in_visual = vim.fn.mode():match("[vV\22]") ~= nil
		-- In a diffview the buffer path is a scratch URI, so swap in a
		-- location the agent can act on; everywhere else `{position}` is
		-- right. The diffview text is concatenated rather than templated
		-- so a path containing braces never reaches the placeholder pass.
		local dv = diffview_location()
		if dv then
			rendered = in_visual and (dv .. "\n\n" .. (Context.get():render({ msg = "{selection}" }) or "")) or dv
		else
			rendered = Context.get():render({ msg = in_visual and "{position}\n\n{selection}" or "{position}" }) or ""
		end
		if in_visual then
			vim.cmd("normal! \27")
		end
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"

	local width = math.min(80, math.max(40, math.floor(vim.o.columns * 0.6)))
	local what = opts.context and "Ask Sidekick" or "Say to Sidekick"
	local title = opts.submit and (" %s — <CR> send · <C-s> queue · <Esc> cancel "):format(what)
		or (" %s — <CR> queue · <C-s> send · <Esc> cancel "):format(what)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor(vim.o.lines / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = 1,
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	})

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		-- Mode is global in Neovim, so leaving the prompt while in
		-- insert mode would carry insert mode into the underlying
		-- buffer. Drop back to normal explicitly.
		vim.cmd("stopinsert")
	end

	local function finish(submit)
		local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		close()
		if input == "" then
			return
		end
		-- Without context there is nothing to separate the input from, and the
		-- blank lines would open the message with two empty ones.
		local final = rendered ~= "" and (rendered .. "\n\n" .. input) or input
		-- focus = false so we stay in the editor instead of being
		-- pulled into the CLI terminal (which lands in terminal/insert).
		cli.send({ text = Text.to_text(final), submit = submit, focus = false })
	end

	local map = function(mode, lhs, fn)
		vim.keymap.set(mode, lhs, fn, { buffer = buf, nowait = true, silent = true })
	end
	map({ "i", "n" }, "<CR>", function()
		finish(opts.submit)
	end)
	map({ "i", "n" }, "<C-s>", function()
		finish(not opts.submit)
	end)
	map({ "i", "n" }, "<Esc>", close)
	map("n", "q", close)

	vim.cmd("startinsert")
end

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
				local row = vim.api.nvim_win_get_cursor(0)[1]

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
								vim.notify(
									"Claude failed: " .. (result.stderr or result.stdout or ""),
									vim.log.levels.ERROR
								)
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
				ask({ submit = true, context = true })
			end,
			mode = { "n", "x" },
			desc = "Sidekick Ask with Context",
		},
		{
			"<leader>aq",
			function()
				ask({ submit = false, context = true })
			end,
			mode = { "n", "x" },
			desc = "Sidekick Queue with Context (submit later)",
		},
		{
			"<leader>an",
			function()
				ask({ submit = true, context = false })
			end,
			desc = "Sidekick Say (no file context)",
		},
	},
}
