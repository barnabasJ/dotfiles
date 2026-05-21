return {
	"3rd/diagram.nvim",
	dependencies = { "3rd/image.nvim" },
	ft = { "markdown" },
	config = function()
		require("diagram").setup({
			integrations = {
				require("diagram.integrations.markdown"),
			},
			renderer_options = {
				mermaid = {
					-- Solid backdrop (catppuccin mocha base) so dark theme boxes
					-- don't blend into the terminal background and become invisible.
					background = "#1e1e2e",
					theme = "dark",
					scale = 4,
				},
			},
		})
	end,
}
