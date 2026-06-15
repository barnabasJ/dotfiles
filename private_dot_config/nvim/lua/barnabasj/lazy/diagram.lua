return {
	"3rd/diagram.nvim",
	dependencies = { "3rd/image.nvim" },
	ft = { "markdown" },
	config = function()
		-- mermaid-cli (mmdc) drives a headless browser via puppeteer. By default
		-- puppeteer-core insists on its own pinned Chrome download under
		-- ~/.cache/puppeteer, which isn't installed here, so rendering fails with
		-- "Could not find Chrome". Point it at the system Google Chrome instead:
		-- it's already present, and its distro package ships a working sandbox
		-- profile, so no puppeteer download or AppArmor workaround is needed.
		-- jobstart() inherits this env, so mmdc picks it up.
		if vim.env.PUPPETEER_EXECUTABLE_PATH == nil then
			local candidates = {
				"/usr/bin/google-chrome",
				"/usr/bin/google-chrome-stable",
				"/usr/bin/chromium",
				"/usr/bin/chromium-browser",
				"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
				"/Applications/Chromium.app/Contents/MacOS/Chromium",
			}
			for _, path in ipairs(candidates) do
				if vim.fn.executable(path) == 1 then
					vim.env.PUPPETEER_EXECUTABLE_PATH = path
					break
				end
			end
		end

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
