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
					-- Scale via cli_args instead of `scale = 8` because the
					-- `scale` option wasn't reaching mmdc (PNG output stayed
					-- at scale=1 size). cli_args is spliced verbatim into the
					-- mmdc invocation, so this is unambiguous.
					cli_args = { "-s", "8" },
				},
			},
		})
	end,
}
