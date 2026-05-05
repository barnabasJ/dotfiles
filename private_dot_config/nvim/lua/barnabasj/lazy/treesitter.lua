-- ============================================================================
-- nvim-treesitter — context for future-you (researched 2026-05-05)
-- ============================================================================
--
-- ## TL;DR
-- The repo is archived. We're on `main` branch, same as every active distro.
-- This is fine. Re-evaluate when neovim/neovim#39006 (`nvim-treeconfig`)
-- materializes — likely 6–12 months out from May 2026.
--
-- ## Why this file exists in this shape
--
-- The repo (https://github.com/nvim-treesitter/nvim-treesitter) was archived
-- on 2026-04-03 with no public announcement. The trigger was visible in
-- discussion #8627 ("Why are there no releases?") where a user told the
-- maintainer (clason) to "switch to something that doesn't require interacting
-- with people". Maintainer burnout, not a technical end-of-life. HN and
-- Lobsters threads overwhelmingly defended clason.
--   - https://github.com/nvim-treesitter/nvim-treesitter/discussions/8627
--   - https://news.ycombinator.com/item?id=47644667
--   - https://lobste.rs/s/jr4acs/nvim_treesitter_repository_was_archived
--
-- Per clason's last status on the roadmap issue, `main` is "stable in the
-- sense that it is feature complete" and targets exactly Nvim 0.12.
--   - https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
--
-- ## Why `main`, not `master`
--
-- `master` is broken on Nvim 0.12 — issue #8636: `attempt to call method
-- 'range' (a nil value)` from `query_predicates.lua:141`, caused by Nvim 0.12
-- changing `match[id]` to return a list of nodes instead of a single node.
-- That file doesn't exist on `main` (it's a full rewrite), so migrating fixes
-- the bug. `master` is locked to Nvim 0.11.
--   - https://github.com/nvim-treesitter/nvim-treesitter/issues/8636
--
-- ## We are not on a fringe path
--
-- Every active distro is on `branch = "main"` and waiting:
--   - LazyVim: moved before the archive. Folke (2026-04-10): "I'll wait a bit
--     to see what comes up as a community alternative."
--     https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua
--   - kickstart.nvim: same `vim.treesitter.start` + `require('nvim-treesitter').install`
--     pattern this file uses. https://github.com/nvim-lua/kickstart.nvim
--   - AstroNvim: on `main`, minimal spec.
--   - LunarVim is itself effectively abandoned (last commit June 2025).
--
-- ## What Neovim core already absorbed (0.12, released 2026-03-29)
--
--   - Treesitter highlighting via `vim.treesitter.start()`
--   - Bundled parsers: c, lua, markdown, vim, vimdoc, query
--   - Built-in incremental selection: `v_an` / `v_in` / `v_]n` / `v_[n`
--     (this is why we dropped the old `node_incremental = "v"` mapping —
--     core covers it now)
--   - Async highlighting/folding (added in 0.11)
--   - Treesitter-driven `commentstring`
--   - `vim.treesitter.foldexpr()`
-- See https://neovim.io/doc/user/news-0.12/
--
-- What core does NOT yet ship: parser installer, the curated query collection
-- for the long tail of languages, language↔filetype registration, indent
-- expression. That's why we still need this plugin.
--
-- ## The official future
--
-- justinmk opened https://github.com/neovim/neovim/issues/39006 on
-- 2026-04-13: "nvim-treeconfig: upstream nvim-treesitter" — proposing a
-- Neovim-team-maintained installer/config plugin modelled on `nvim-lspconfig`.
-- justinmk's own words: "this is all vaporware currently." But this is the
-- documented plan. When it ships we likely drop this file entirely.
--
-- ## Forks (none worth switching to as of 2026-05-05)
--
--   - tree-sitter-manager.nvim (496⭐, romus204): only solves parser install,
--     TUI-focused. LazyVim co-maintainer judged it "not useful for the way
--     LazyVim is structured."
--   - arborist.nvim (144⭐): author already offered to hand over or deprecate
--     pending community direction.
--   - The org name `neovim-treesitter/nvim-treesitter` is misleading — sounds
--     official, is one person (George Harker), 73⭐, 0 forks. Don't confuse
--     with the real archived repo at `nvim-treesitter/nvim-treesitter`.
--
-- ## Source of the setup pattern below
--
-- The `main` branch README — the only documented setup the maintainers left:
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md
-- Cross-checked against kickstart.nvim's init.lua.
--
-- ## Things we dropped from the old (master-branch) config
--
--   - `auto_install = true` — `main` removed the option. We re-implement it
--     manually in the FileType autocmd below: if a parser isn't installed but
--     IS in the nvim-treesitter parser registry, fire `ts.install({lang})`
--     async and re-run vim.treesitter.start when it finishes.
--   - `incremental_selection` (was `v` / `V`) — Nvim 0.12 ships built-in.
--   - `additional_vim_regex_highlighting = { "ruby" }` — semantically a no-op
--     on main: `vim.treesitter.start()` doesn't disable Vim regex syntax.
--   - `indent.disable = { "ruby" }` — preserved via the `if ft ~= "ruby"`
--     branch below.
-- ============================================================================
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	-- README "Installation": main does not support lazy-loading; must load at
	-- startup with `lazy = false` and run `:TSUpdate` on plugin updates.
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		-- We MUST pass install_dir explicitly — `setup()` only prepends it
		-- to `runtimepath` when given a value. Lazy.nvim's default
		-- `performance.rtp.reset = true` strips `stdpath('data')/site` from
		-- rtp, so without this prepend Neovim can't find installed parsers
		-- or queries even though they're on disk. Symptom: a parser appears
		-- in `:checkhealth nvim-treesitter` and `get_installed("parsers")`
		-- but `vim.treesitter.start()` does nothing.
		ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

		-- README "Installation": parsers are installed explicitly via
		-- `require('nvim-treesitter').install({...})`. There is no
		-- `auto_install` / `ensure_installed` option anymore.
		--
		-- Eager-install everything we hit often. Less common langs are picked
		-- up by the auto-install fallback in the FileType autocmd below, which
		-- is what restores the old `auto_install = true` behavior we lost in
		-- the master→main migration.
		ts.install({
			"bash",
			"c",
			"comment",
			"css",
			"diff",
			"dockerfile",
			"eex",
			"elixir",
			"gitcommit",
			"gitignore",
			"go",
			"heex",
			"html",
			"javascript",
			"jsdoc",
			"json",
			"jsonc",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"regex",
			"rust",
			"sql",
			"toml",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
			"zig",
		})

		local function enable_for_buf(buf)
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			-- README "Highlighting": features are no longer auto-enabled —
			-- `vim.treesitter.start()` must be called per-buffer (see
			-- `:h treesitter-highlight`).
			if not pcall(vim.treesitter.start, buf) then
				return
			end
			-- README "Indentation": opt-in via this exact indentexpr value
			-- (note the embedded single quotes — they're required).
			-- Skipping ruby preserves the previous `indent.disable = { "ruby" }`.
			if vim.bo[buf].filetype ~= "ruby" then
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end

		-- Track in-flight installs so a flurry of FileType events for the
		-- same lang doesn't fire N parallel installs.
		local installing = {}

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				local ft = vim.bo[buf].filetype
				local lang = vim.treesitter.language.get_lang(ft) or ft

				-- Fast path: parser already installed.
				if vim.list_contains(require("nvim-treesitter.config").get_installed("parsers"), lang) then
					enable_for_buf(buf)
					return
				end

				-- Auto-install fallback (replaces old `auto_install = true`).
				-- Only install parsers nvim-treesitter actually knows about.
				if installing[lang] or not require("nvim-treesitter.parsers")[lang] then
					return
				end
				installing[lang] = true
				ts.install({ lang }):await(function()
					vim.schedule(function()
						installing[lang] = nil
						enable_for_buf(buf)
					end)
				end)
			end,
		})
	end,
}
