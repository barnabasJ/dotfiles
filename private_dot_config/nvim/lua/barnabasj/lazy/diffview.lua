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
			"<leader>gC",
			function()
				Snacks.picker.git_log({
					-- Walk only the first-parent line so item.idx (1-based) matches
					-- HEAD~N exactly. Without this, git log interleaves both parents
					-- of merge commits by date and the labels drift.
					cmd_args = { "--first-parent" },
					format = function(item, picker)
						local ret = {}
						-- git log streams in reverse-chronological order, so idx 1 == HEAD,
						-- idx 2 == HEAD~1, etc. Surface that as a leading column so it's
						-- obvious which commit is "the previous one" without counting.
						local label = item.idx == 1 and "HEAD" or ("HEAD~" .. (item.idx - 1))
						ret[#ret + 1] = { Snacks.picker.util.align(label, 7), "SnacksPickerGitCommit" }
						ret[#ret + 1] = { " " }
						Snacks.picker.highlight.extend(ret, Snacks.picker.format.git_log(item, picker))
						return ret
					end,
					confirm = function(picker, item)
						picker:close()
						if item and item.commit then
							vim.cmd("DiffviewClose")
							vim.cmd("DiffviewOpen " .. item.commit)
						end
					end,
				})
			end,
			desc = "Diff against commit",
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
