return {
	"elixir-tools/elixir-tools.nvim",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local elixir = require("elixir")
		local elixirls = require("elixir.elixirls")

		elixir.setup({
			elixirls = {
				enable = true,
			},
		})
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}
