return {
	"folke/trouble.nvim",
	opts = {
		modes = {
			-- Enhanced diagnostics mode with preview
			diagnostics = {
				mode = "diagnostics",
				preview = {
					type = "split",
					relative = "win",
					position = "right",
					size = 0.3,
				},
				focus = true,
				win = {
					position = "bottom",
					size = 0.3,
				},
				format = "{file_icon} {filename} {pos} {item.message}",
			},
		},
	},
	cmd = "Trouble",
	keys = {
		-- Diagnostics
		{
			"<leader>qq",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		-- Other Trouble features
		{
			"<leader>xs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>xl",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xQ",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
	},
}
