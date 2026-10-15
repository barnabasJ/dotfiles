return {
	"mfussenegger/nvim-dap",
	url = "https://codeberg.org/mfussenegger/nvim-dap.git",
	ft = { "elixir" },
	cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver", "DapStepInto", "DapStepOut", "DapTerminate" },
	keys = {
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Debug: start / continue",
		},
		{
			"<leader>dt",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: toggle breakpoint",
		},
		{
			"<leader>dn",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: step over",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: step into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: step out",
		},
		{
			"<leader>dx",
			function()
				require("dap").terminate()
			end,
			desc = "Debug: stop",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "Debug: open REPL / output",
		},
		{
			"<leader>dv",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end,
			desc = "Debug: inspect scopes",
		},
	},
	config = function()
		local dap = require("dap")
		require("barnabasj.edb").setup(dap)
		local mise_data = vim.env.MISE_DATA_DIR
			or ((vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/mise")
		local otp_bin = vim.env.EDB_OTP_BIN or (mise_data .. "/installs/erlang/29.1/bin")
		local elixir_bin = vim.env.EDB_ELIXIR_BIN or (mise_data .. "/installs/elixir/1.20.4-otp-29/bin")
		local edb_root = vim.env.EDB_ROOT or vim.fn.expand("~/sandbox/edb")
		local edb = vim.env.EDB or vim.fn.exepath("edb")
		if edb == "" then
			edb = edb_root .. "/_build/default/bin/edb"
		end
		local runtime_bins = {}
		for _, bin in ipairs({ otp_bin, elixir_bin }) do
			if vim.fn.isdirectory(bin) == 1 then
				table.insert(runtime_bins, bin)
			end
		end
		table.insert(runtime_bins, vim.env.PATH or "")
		local runtime_path = table.concat(runtime_bins, ":")
		local mix = vim.fn.executable(elixir_bin .. "/mix") == 1 and (elixir_bin .. "/mix") or vim.fn.exepath("mix")

		-- Prefer the installed debugger runtimes without changing project defaults.
		-- Nix shells can provide compatible runtimes on PATH instead.
		dap.adapters.edb = {
			type = "executable",
			command = vim.fn.exepath("env"),
			args = { "PATH=" .. runtime_path, edb, "dap" },
		}

		local function test_run(at_cursor)
			assert(vim.fn.executable(edb) == 1, "Build edb with OTP 29 or set EDB to its executable")
			assert(mix ~= "", "Install Elixir for OTP 29 or set EDB_ELIXIR_BIN")
			local file = vim.api.nvim_buf_get_name(0)
			assert(file:match("%.exs$"), "Open an ExUnit .exs test file first")
			local root = assert(vim.fs.root(file, "mix.exs"), "No Mix project found for this file")
			local selection = vim.fs.relpath(root, file)
			if at_cursor then
				selection = selection .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
			end
			return {
				cwd = root,
				args = { mix, "edb.test", selection, "--seed", "0" },
				env = { MIX_ENV = "test", PATH = runtime_path },
			}
		end

		local function test_configuration(name, at_cursor)
			return {
				type = "edb",
				request = "launch",
				name = name,
				run = function()
					return test_run(at_cursor)
				end,
				config = {
					language = "elixir",
					nameDomain = "shortnames",
					nodeInitCodeInEnvVar = "EDB_DAP_DEBUGGEE_INIT",
					timeout = 300,
				},
			}
		end

		dap.configurations.elixir = dap.configurations.elixir or {}
		table.insert(dap.configurations.elixir, test_configuration("edb: test at cursor", true))
		table.insert(dap.configurations.elixir, test_configuration("edb: current test file", false))
		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })
	end,
}
