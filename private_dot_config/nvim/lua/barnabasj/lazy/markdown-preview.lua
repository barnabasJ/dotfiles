return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function(plugin)
		-- lazy.nvim runs build callbacks before a freshly cloned plugin is on
		-- runtimepath. Add only this directory while invoking markdown-preview's
		-- documented installer, then restore runtimepath even if it fails.
		-- https://github.com/iamcco/markdown-preview.nvim#install-with-lazynvim
		vim.opt.runtimepath:append(plugin.dir)
		local ok, err = pcall(vim.fn["mkdp#util#install"], true)
		vim.opt.runtimepath:remove(plugin.dir)
		if not ok then
			error(err)
		end
	end,
}
