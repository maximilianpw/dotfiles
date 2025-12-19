return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = { enabled = false },
			suggestion = {
				enabled = false,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<M-l>",
					accept_word = "<M-w>",
					accept_line = "<M-e>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			copilot_node_command = vim.fn.filereadable("/etc/NIXOS") == 1 and vim.g.node_host_prog
				or "/opt/homebrew/bin/node",
		},
	},
}
