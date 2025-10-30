return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- ═══════════════════════════════════════════════════════════════
		-- 🎨 VISUAL & UI ENHANCEMENTS
		-- ═══════════════════════════════════════════════════════════════

		-- Visual indentation guides with scope highlighting
		indent = { enabled = true },
		-- Enhanced input dialogs with better UX
		input = { enabled = true },
		-- Beautiful notification system with animations
		notifier = { enabled = true },
		-- Scope-aware operations and highlighting
		scope = { enabled = true },
		-- Smooth scrolling animations
		scroll = { enabled = true },
		-- Advanced status column (disabled - set in options.lua)
		statuscolumn = { enabled = false },

		-- ═══════════════════════════════════════════════════════════════
		-- 🔍 SEARCH & PICKER SYSTEM (Telescope Replacement)
		-- ═══════════════════════════════════════════════════════════════
		-- Universal fuzzy finder - replaces Telescope entirely
		picker = {
			enabled = true,
			-- Enhanced matcher for better fuzzy finding
			matcher = {
				fuzzy = true,
				smartcase = true,
				ignorecase = true,
				filename_bonus = true,
				file_pos = true,
				sort_empty = false,
			},
		},

		-- ═══════════════════════════════════════════════════════════════
		-- 💻 TERMINAL & DEVELOPMENT TOOLS
		-- ═══════════════════════════════════════════════════════════════

		-- Repository browsing and remote Git operations
		gitbrowse = { enabled = true },

		-- Git blame and history integration
		git = { enabled = true },

		-- lazygit
		lazygit = { enabled = true },

		-- ═══════════════════════════════════════════════════════════════
		-- ⚡ PRODUCTIVITY & WORKFLOW
		-- ═══════════════════════════════════════════════════════════════

		-- Feature toggles and quick settings
		toggle = { enabled = true },

		-- Debug tools and inspection utilities
		debug = { enabled = true },

		-- Buffer deletion without disrupting layout
		bufdelete = { enabled = true },

		-- Smart file/symbol renaming with LSP integration
		rename = { enabled = true },

		-- Large file handling and optimization
		bigfile = { enabled = true },

		-- Quick file operations and access
		quickfile = { enabled = true },

		-- Word movement and selection enhancements with LSP references
		words = { enabled = true },

		-- File explorer integration (disabled in favor of neo-tree)
		explorer = { enabled = false },

		-- ═══════════════════════════════════════════════════════════════
		-- 🏠 DASHBOARD CONFIGURATION
		-- ═══════════════════════════════════════════════════════════════
		dashboard = {
			enabled = true,
			preset = {
				width = 80,
				sections = {
					{
						section = "header",
						width = 40,
						padding = 1,
					},
					{
						section = "keys",
						height = 5,
						padding = 1,
					},
					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
					{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				},
				-- Dashboard quick action keys (using Snacks picker)
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = function()
							require("snacks").picker.files()
						end,
					},
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = function()
							require("snacks").picker.grep()
						end,
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = function()
							require("snacks").picker.recent()
						end,
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							require("snacks").picker.files({ cwd = "~/.local/share/chezmoi/dot_config/nvim" })
						end,
					},
					{
						icon = "󰒲 ",
						key = "l",
						desc = "Lazy",
						action = function()
							if vim.fn.exists(":Lazy") == 2 then
								vim.cmd("Lazy")
							else
								print("Lazy.nvim not available")
							end
						end,
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
	},
	-- ═══════════════════════════════════════════════════════════════
	-- ⌨️  COMPREHENSIVE KEYMAPS FOR ALL SNACKS FEATURES
	-- ═══════════════════════════════════════════════════════════════
	keys = {
		-- ────────────────────────────────────────────────────────────
		-- 🔍 PICKER SYSTEM (Telescope replacement)
		-- ────────────────────────────────────────────────────────────
		{
			"<leader>ff",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fl",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Find by Grep (Live)",
		},
		{
			"<leader>fd",
			function()
				require("snacks").picker.diagnostics()
			end,
			desc = "Find Diagnostics",
		},
		{
			"<leader>fD",
			function()
				require("snacks").picker.diagnostics({ severity = vim.diagnostic.severity.ERROR })
			end,
			desc = "Find Errors Only",
		},
		{
			"<leader><leader>",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Find existing buffers",
		},
		{
			"<leader>f.",
			function()
				require("snacks").picker.recent()
			end,
			desc = "Find Recent Files",
		},
		{
			"<leader>fh",
			function()
				require("snacks").picker.help()
			end,
			desc = "Find Help",
		},
		{
			"<leader>fk",
			function()
				require("snacks").picker.keymaps()
			end,
			desc = "Search Keymaps",
		},
		{
			"<leader>fc",
			function()
				require("snacks").picker.files({ cwd = "~/.local/share/chezmoi/dot_config/nvim" })
			end,
			desc = "Find Config Files",
		},
		{
			"<leader>fw",
			function()
				require("snacks").picker.grep_word()
			end,
			desc = "Find current Word",
		},
		{
			"<leader>fs",
			function()
				require("snacks").picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>fu",
			function()
				require("snacks").picker.undo()
			end,
			desc = "Undo History",
		},
		-- Git related pickers (matching your telescope git keymaps)
		{
			"<leader>fgf",
			function()
				require("snacks").picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>fgb",
			function()
				require("snacks").picker.git_branches()
			end,
			desc = "Checkout Git Branch",
		},
		{
			"<leader>fgc",
			function()
				require("snacks").picker.git_log()
			end,
			desc = "Checkout Commit (Git Log)",
		},
		-- Search in current buffer (matching your telescope config)
		{
			"<leader>/",
			function()
				require("snacks").picker.lines()
			end,
			desc = "Fuzzily search in current buffer",
		},
		-- Grep in open files (matching your telescope config)
		{
			"<leader>f/",
			function()
				require("snacks").picker.grep_buffers()
			end,
			desc = "Grep in Open Files",
		},

		-- ────────────────────────────────────────────────────────────
		-- 📋 NOTIFICATIONS & DEBUG
		-- ────────────────────────────────────────────────────────────
		{
			"<leader>nn",
			function()
				require("snacks").notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>nd",
			function()
				require("snacks").notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},

		-- ────────────────────────────────────────────────────────────
		-- 🌿 GIT INTEGRATION
		-- ────────────────────────────────────────────────────────────
		{
			"<leader>gg",
			function()
				require("snacks").lazygit.open()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>D",
			function()
				vim.cmd("terminal lazydocker")
			end,
			desc = "Lazydocker",
		},
		{
			"<leader>gf",
			function()
				require("snacks").lazygit.log_file()
			end,
			desc = "Lazygit Current File History",
		},
		{
			"<leader>gl",
			function()
				require("snacks").lazygit.log()
			end,
			desc = "Lazygit Log (cwd)",
		},
		{
			"<leader>gb",
			function()
				require("snacks").git.blame_line()
			end,
			desc = "Git Blame Line",
		},
		{
			"<leader>gB",
			function()
				require("snacks").gitbrowse()
			end,
			desc = "Git Browse (Open in Browser)",
		},

		-- ────────────────────────────────────────────────────────────
		-- ⚡ PRODUCTIVITY & WORKFLOW
		-- ────────────────────────────────────────────────────────────
		{
			"<leader>bd",
			function()
				require("snacks").bufdelete()
			end,
			desc = "Delete Buffer (preserve layout)",
		},
	},
	init = function()
		-- ═══════════════════════════════════════════════════════════════
		-- 🚀 INITIALIZATION & AUTO-SETUP
		-- ═══════════════════════════════════════════════════════════════

		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- ────────────────────────────────────────────────────────────
				-- 🎨 UI CUSTOMIZATION
				-- ────────────────────────────────────────────────────────────
				local dashboard_blue = "#89B4FA"
				vim.api.nvim_set_hl(0, "SnacksDashboardHeader", {
					fg = dashboard_blue,
					bold = true,
				})
			end,
		})
	end,
}
