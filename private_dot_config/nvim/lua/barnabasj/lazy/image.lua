return {
	"3rd/image.nvim",
	-- Load on markdown (inline images + mermaid via diagram.nvim) AND when an
	-- image file is opened directly. image.nvim renders standalone images via a
	-- BufWinEnter "hijack" autocmd (hijack_file_patterns), but that autocmd is
	-- only registered when the plugin's setup() runs. With `ft = { "markdown" }`
	-- alone, opening a *.png in a fresh session never loaded the plugin, so the
	-- hijack never registered and the PNG showed as binary garbage — it only
	-- "worked" if a markdown buffer had been opened earlier that session. Adding
	-- BufReadPre on image patterns loads it before BufWinEnter fires, so directly
	-- opened screenshots (e.g. logseq_mcp's e2e/QA PNGs) render reliably.
	ft = { "markdown" },
	event = {
		"BufReadPre *.png",
		"BufReadPre *.jpg",
		"BufReadPre *.jpeg",
		"BufReadPre *.gif",
		"BufReadPre *.webp",
		"BufReadPre *.avif",
	},
	opts = {
		-- Ghostty implements the full Kitty graphics protocol (delete ops,
		-- animations, unicode placeholders). Use it — faster, cleaner
		-- clipping, and proper image cleanup on buffer/tab switch (which
		-- Sixel couldn't do because the Sixel protocol has no delete op).
		backend = "kitty",
		processor = "magick_rock",
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown" },
			},
			neorg = { enabled = false },
			typst = { enabled = false },
			html = { enabled = false },
			css = { enabled = false },
		},
		-- Keep at 1.0 — anything above stretches the PNG across more cells
		-- than its pixel count supports, and the terminal interpolates,
		-- producing visible blur. For "bigger diagrams" we instead render
		-- a bigger PNG via mmdc's `scale` in diagram.lua.
		scale_factor = 1.0,
		-- Ceilings only — the smaller of (natural × scale_factor) and these
		-- wins. 80% of the window keeps full-screen diagrams from blowing
		-- off the visible area.
		max_width_window_percentage = 80,
		max_height_window_percentage = 80,
		window_overlap_clear_enabled = true,
		editor_only_render_when_focused = true,
		tmux_show_only_in_active_window = true,
	},
	config = function(_, opts)
		require("image").setup(opts)

		-- Recovery for ghost/stale images. image.nvim clears on buffer/window/
		-- tab leave and on FocusLost, but switching tmux SESSIONS doesn't
		-- deliver a focus-out to this nvim, so a lingering image can survive
		-- (upstream image.nvim #233 — no complete config fix). On the kitty
		-- backend clear() issues real delete ops, so this reliably wipes any
		-- leftover. Manual because there's no nvim event to hook for that case.
		vim.api.nvim_create_user_command("ImageClear", function()
			require("image").clear()
		end, { desc = "Clear all rendered images (recover from ghost/stale images)" })

		vim.keymap.set("n", "<leader>ic", "<cmd>ImageClear<cr>", { desc = "[I]mage: [C]lear ghosts" })

		-- Optional aggressive auto-clear, left OFF on purpose: image.nvim already
		-- clears a buffer's images on BufLeave/WinClosed/TabEnter, so this is
		-- redundant for file switching AND it clears ALL images, which would wipe
		-- diagrams still visible in other split windows (flicker/over-clear). It
		-- also can't fix the real gap (tmux session switch fires no nvim event).
		-- Enable only if you want every buffer/tab switch to wipe all images:
		-- vim.api.nvim_create_autocmd({ "BufLeave", "TabLeave" }, {
		-- 	callback = function() pcall(require("image").clear) end,
		-- })
	end,
}
