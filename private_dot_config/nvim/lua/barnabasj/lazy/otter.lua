-- otter.nvim — LSP for languages embedded via treesitter injection.
--
-- For us: colocated JavaScript/CSS inside <script>/<style> tags in HEEx
-- (~H sigils in .ex files), exposed by our patched heex parser's `raw_text`
-- node (see treesitter.lua). otter creates a hidden per-language buffer from
-- each injected region and forwards completion/hover/diagnostics to the real
-- language server (ts_ls for JS, css_variables/cssls for CSS — see mason.lua).
-- Completion surfaces through blink.cmp's normal `lsp` source automatically.
--
-- Caveats (inherent to the hidden-buffer approach, see notes in chat):
--   * No cross-file links to your *other* JS modules, and bare package
--     imports need a jsconfig.json paths shim (assets/node_modules) to
--     resolve, because the hidden buffer is anchored next to the .ex file.
--   * CSS *variable* completion works because css_variables indexes the
--     workspace itself rather than relying on the buffer's project membership.
---@type LazySpec
return {
	"jmbuhr/otter.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "elixir", "heex", "eelixir" },
	opts = {
		lsp = {
			-- Refresh embedded diagnostics on save (cheaper than on every edit).
			diagnostic_update_events = { "BufWritePost" },
		},
		buffers = {
			set_filetype = true,
			write_to_disk = false,
		},
		handle_leading_whitespace = true,
	},
	config = function(_, opts)
		require("otter").setup(opts)

		-- ---------------------------------------------------------------------
		-- Fix otter's multi-client completion bug.
		--
		-- otter-ls forwards a request to the hidden buffer with
		-- `vim.lsp.buf_request`, whose callback fires once PER attached client
		-- and replies on the FIRST to answer. When both `cssls` (general CSS)
		-- and `css_variables` (cross-file var(--…)) are attached, the one that
		-- returns nothing at the cursor (e.g. css_variables on a plain property)
		-- often answers first and shadows the other → zero completions. Same for
		-- ts_ls alongside anything on the JS side.
		--
		-- Upstream is still first-wins (checked origin/main). So we wrap
		-- buf_request to AGGREGATE: for completion on an otter buffer, query all
		-- completion-capable clients and reply once with the merged items. We
		-- aggregate via `client:request` (not buf_request_all, which is itself
		-- built on buf_request and would recurse through this wrapper). If otter
		-- ever fixes this upstream, the wrapper simply stops matching and is a
		-- no-op. Applied once.
		-- ---------------------------------------------------------------------
		if not vim.g.__otter_completion_aggregation then
			vim.g.__otter_completion_aggregation = true
			local ms = vim.lsp.protocol.Methods
			local orig_buf_request = vim.lsp.buf_request

			local function is_otter_buf(bufnr)
				local ok, keeper = pcall(require, "otter.keeper")
				if not ok then
					return false
				end
				for _, raft in pairs(keeper.rafts or {}) do
					for _, otter_nr in pairs(raft.buffers or {}) do
						if otter_nr == bufnr then
							return true
						end
					end
				end
				return false
			end

			vim.lsp.buf_request = function(bufnr, method, params, handler)
				if method ~= ms.textDocument_completion or not is_otter_buf(bufnr) then
					return orig_buf_request(bufnr, method, params, handler)
				end

				local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
				local items, remaining, replied = {}, #clients, false
				local function reply()
					if not replied then
						replied = true
						handler(nil, { isIncomplete = true, items = items },
							{ bufnr = bufnr, method = method, params = params })
					end
				end
				if remaining == 0 then
					reply()
					return {}
				end
				local function on_one(result)
					if result then
						for _, item in ipairs(result.items or result) do
							items[#items + 1] = item
						end
					end
					remaining = remaining - 1
					if remaining == 0 then
						reply()
					end
				end
				for _, client in ipairs(clients) do
					local ok = client:request(method, params, function(_, result)
						on_one(result)
					end, bufnr)
					if not ok then
						on_one(nil)
					end
				end
				return {}
			end
		end

		-- Activate per buffer. otter reads the injection query for the buffer's
		-- language, so it picks up javascript (script) and css (style) regions —
		-- and it is graceful when a file has none. pcall: never let a parse hiccup
		-- block opening an Elixir file.
		local group = vim.api.nvim_create_augroup("otter-elixir-heex", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = { "elixir", "heex", "eelixir" },
			callback = function()
				pcall(require("otter").activate, { "javascript", "css" }, true, true)
			end,
		})
	end,
}
