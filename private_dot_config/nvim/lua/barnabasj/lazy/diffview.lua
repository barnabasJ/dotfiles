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
			"<leader>gp",
			function()
				-- PR-review flow: pick the base off the graph, then the branch under
				-- review. `base...head` is merge-base semantics -- the same set of
				-- changes a PR shows, not every commit base has gained since. The
				-- pickers are chained rather than shown side by side because Snacks
				-- runs one at a time; the second opens from `vim.schedule` so the
				-- first has finished tearing its window down.
				local graph = require("barnabasj.git_graph")
				graph.pick({
					title = "PR Review — base (<a-a> for all branches)",
					on_choose = function(base)
						vim.schedule(function()
							graph.pick({
								title = "PR Review — branch under review (<a-a> for all branches)",
								on_choose = function(head)
									vim.cmd("DiffviewClose")
									-- --imply-local swaps whichever side resolves to HEAD for the
									-- working tree, so reviewing the checked-out branch leaves the
									-- right pane editable and agent fixes land in the real files
									-- (refresh with <leader>gR). It is a no-op when neither side
									-- is HEAD, so it is always safe to pass.
									vim.cmd(
										("DiffviewOpen %s...%s --imply-local"):format(
											base.branch or base.commit,
											head.branch or head.commit
										)
									)
								end,
							})
						end)
					end,
				})
			end,
			desc = "PR review: diff two branches (graph)",
		},
		{
			"<leader>gc",
			function()
				local graph = require("barnabasj.git_graph")
				graph.pick({
					title = "Checkout… (<a-a> for all branches)",
					on_choose = graph.checkout,
				})
			end,
			desc = "Checkout branch (graph)",
		},
		{
			"<leader>gD",
			function()
				require("barnabasj.git_graph").pick({
					title = "Diff against… (<c-o> checkout, <a-a> all branches)",
					on_choose = function(choice)
						vim.cmd("DiffviewClose")
						vim.cmd(("DiffviewOpen %s --imply-local"):format(choice.branch or choice.commit))
					end,
				})
			end,
			desc = "Diff against branch (graph)",
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
		-- Stack maps. `barnabasj.git_stack` resolves the chain of branches HEAD
		-- sits in and each branch's base commit; see that module for where the
		-- data comes from. All of them lazy-load diffview through this spec.
		{
			"<leader>gv",
			function()
				require("barnabasj.git_stack").pick()
			end,
			desc = "Stack: view (<c-o> checkout, <a-b> vs root, <a-o> open PR)",
		},
		{
			"<leader>gg",
			function()
				local stack = require("barnabasj.git_stack")
				local s = stack.get()
				local i = s and stack.index(s)
				if i then
					stack.diff_branch(s.branches[i])
				elseif s then
					vim.notify("git-stack: HEAD is not on a stack branch", vim.log.levels.WARN)
				end
			end,
			desc = "Stack: diff this branch against its base (the PR diff)",
		},
		{
			"<leader>gr",
			function()
				local stack = require("barnabasj.git_stack")
				local s = stack.get()
				if s then
					stack.diff_root(s)
				end
			end,
			-- Not the same as <leader>gm: that one diffs against wherever origin/main
			-- has got to, this one against the commit the stack actually forked from,
			-- so nobody else's merges leak into the diff.
			desc = "Stack: diff against the trunk commit the stack forked from",
		},
		{
			"<leader>gk",
			function()
				require("barnabasj.git_stack").move(1)
			end,
			desc = "Stack: up (away from trunk)",
		},
		{
			"<leader>gj",
			function()
				require("barnabasj.git_stack").move(-1)
			end,
			desc = "Stack: down (toward trunk)",
		},
		{
			"<leader>gK",
			function()
				require("barnabasj.git_stack").jump("top")
			end,
			desc = "Stack: to the top",
		},
		{
			"<leader>gJ",
			function()
				require("barnabasj.git_stack").jump("bottom")
			end,
			desc = "Stack: to the bottom",
		},
	},
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
}
