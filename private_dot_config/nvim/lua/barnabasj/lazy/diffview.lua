---@type LazySpec
return {
	"sindrets/diffview.nvim",
	keys = {
		{
			"<leader>gm",
			function()
				vim.cmd("DiffviewClose")
				vim.cmd("DiffviewOpen origin/main")
			end,
			desc = "Diff against origin/main",
		},
		{
			"<leader>gD",
			function()
				Snacks.picker.git_branches({
					confirm = function(picker, item)
						picker:close()
						if item then
							vim.cmd("DiffviewClose")
							vim.cmd("DiffviewOpen " .. item.branch)
						end
					end,
				})
			end,
			desc = "Diff against branch",
		},
		{
			"<leader>gR",
			function()
				local view = require("diffview.lib").get_current_view()
				if view then
					view:update_files()
				end
			end,
			desc = "Refresh diffview",
		},
	},
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
}
