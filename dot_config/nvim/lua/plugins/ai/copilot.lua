return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = { enabled = false },
			suggestion = { enabled = false },
			copilot_node_command = vim.fn.filereadable("/etc/NIXOS") == 1
				and vim.g.node_host_prog
				or "/opt/homebrew/bin/node",
		},
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "zbirenbaum/copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
