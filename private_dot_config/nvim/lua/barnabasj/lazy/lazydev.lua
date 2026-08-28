---@type LazySpec
return {
	"folke/lazydev.nvim",
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			"lazy.nvim",
			"snacks.nvim",
			-- See the configuration section for more details
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			-- Spec files run under plenary's busted, whose globals (describe, it,
			-- before_each) and luassert-backed `assert` are otherwise undefined.
			-- busted's own library binds `assert = require("luassert")`, so both
			-- have to come in together.
			{ path = "${3rd}/busted/library", words = { "describe" } },
			{ path = "${3rd}/luassert/library", words = { "describe", "assert%." } },
		},
	},
}
