---@type LazySpec
return {
	"sindrets/diffview.nvim",
	keys = {
		{
			"<leader>gm",
			"<cmd>DiffviewOpen origin/main<cr>",
			desc = "Diff against origin/main",
		},
		{
			"<leader>gD",
			function()
				Snacks.picker.git_branches({
					confirm = function(picker, item)
						picker:close()
						if item then
							vim.cmd("DiffviewOpen " .. item.branch)
						end
					end,
				})
			end,
			desc = "Diff against branch",
		},
	},
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
}
