return {
	"3rd/image.nvim",
	ft = { "markdown" },
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
		max_width = 100,
		max_height = 30,
		max_width_window_percentage = nil,
		max_height_window_percentage = 50,
		window_overlap_clear_enabled = true,
		editor_only_render_when_focused = true,
		tmux_show_only_in_active_window = true,
	},
}
