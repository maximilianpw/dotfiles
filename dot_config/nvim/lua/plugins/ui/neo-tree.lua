return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- optional, for icons
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	keys = {
		{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
		{ "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus Neo-tree" },
	},
	opts = {
		close_if_last_window = true, -- Close Neo-tree if it's the last window
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = true,
		filesystem = {
			follow_current_file = { enabled = true }, -- Auto follow current file
			hijack_netrw_behavior = "open_default", -- Replace netrw
			use_libuv_file_watcher = true, -- Auto update
		},
		window = {
			position = "left",
			width = 35,
		},
		buffers = {
			follow_current_file = { enabled = true },
		},
		git_status = {
			window = { position = "float" },
		},
	},
}
