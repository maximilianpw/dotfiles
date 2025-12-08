return {
	"dmtrKovalenko/fff.nvim",
	build = "cargo build --release",
	keys = {
		{
			"<leader>ff",
			function()
				require("fff").find_files()
			end,
			desc = "Find Files (fff)",
		},
	},
	opts = {
		prompt = "❯ ",
		title = "Find Files",
	},
}
