return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/Documents/obsidian vault",
			},
		},
		completion = {
			nvim_cmp = false,
			blink = true,
		},
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<leader>ch"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
			["<cr>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
	},
	config = function(_, opts)
		require("obsidian").setup(opts)
		vim.opt_local.conceallevel = 2
	end,
	keys = {
		{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Note" },
		{ "<leader>oo", "<cmd>ObsidianSearch<cr>", desc = "Search Notes" },
		{ "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
		{ "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Tags" },
		{ "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's Note" },
		{ "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's Note" },
		{ "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "Link", mode = "v" },
		{ "<leader>oL", "<cmd>ObsidianLinkNew<cr>", desc = "Link New", mode = "v" },
	},
}
