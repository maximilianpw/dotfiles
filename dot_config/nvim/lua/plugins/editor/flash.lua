return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		-- Label characters for jump targets
		labels = "asdfghjklqwertyuiopzxcvbnm",
		-- Search settings
		search = {
			-- Multi-window search
			multi_window = true,
			-- Forward/backward search
			forward = true,
			-- Wrap search around file
			wrap = true,
			-- Mode can be exact, search, fuzzy
			mode = "exact",
			-- Incremental search
			incremental = false,
		},
		-- Jump settings
		jump = {
			-- Jump position
			jumplist = true,
			-- Jump on partial input
			pos = "start",
			-- Auto jump when there's only one match
			autojump = false,
			-- Clear highlight after jump
			nohlsearch = false,
		},
		-- Label settings
		label = {
			-- Show labels after cursor
			after = true,
			-- Show labels before cursor
			before = false,
			-- Uppercase labels
			uppercase = true,
			-- Reuse labels
			reuse = "lowercase",
			-- Style rainbow for better visibility
			rainbow = {
				enabled = false,
				shade = 5,
			},
		},
		-- Highlight settings
		highlight = {
			-- Show backdrop
			backdrop = true,
			-- Match highlight groups
			matches = true,
		},
		-- Mode-specific settings
		modes = {
			-- Character-based search (s/S)
			char = {
				enabled = true,
				-- Keys to use for labeling
				keys = { "f", "F", "t", "T", ";", "," },
				-- Search across all windows
				multi_line = true,
				-- Character input mode
				label = { exclude = "hjkliardc" },
				-- Highlight matches
				highlight = { backdrop = true },
				-- Jump on any key
				jump = { autojump = true },
			},
			-- Treesitter search
			treesitter = {
				labels = "abcdefghijklmnopqrstuvwxyz",
				jump = { pos = "range" },
				highlight = {
					backdrop = false,
					matches = false,
				},
			},
			-- Remote operations (yank, delete, change from distance)
			remote = {
				remote_op = { restore = true, motion = true },
			},
		},
		-- Prompt settings
		prompt = {
			enabled = true,
			prefix = { { "⚡", "FlashPromptIcon" } },
		},
	},
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
		{
			"<c-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
}
