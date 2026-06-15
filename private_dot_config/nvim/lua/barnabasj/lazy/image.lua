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
}
