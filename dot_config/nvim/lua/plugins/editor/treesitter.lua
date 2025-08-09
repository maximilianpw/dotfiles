-- Treesitter configuration for syntax highlighting
local function should_disable(lang, buf)
	local name = vim.api.nvim_buf_get_name(buf)
	-- 1) Skip any buffer in node_modules or vendor
	if name:match("/node_modules/") or name:match("/vendor/") then
		return true
	end
	-- 2) Skip files over 200 KB
	local ok, stat = pcall(vim.loop.fs_stat, name)
	if ok and stat and stat.size > 200 * 1024 then
		return true
	end
	-- 3) Skip Ruby indent highlighting if you still want regex indent
	if lang == "ruby" then
		return true
	end
	return false
end

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = { "bash", "html", "lua", "markdown", "vim" },
		auto_install = false,
		sync_install = false,
		ignore_install = { "php" },

		highlight = {
			enable = true,
			disable = should_disable,
			additional_vim_regex_highlighting = { "ruby" },
		},

		indent = {
			enable = true,
			disable = should_disable,
		},

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},

		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
		},

		playground = { enable = true },
		context_playground = { enable = true },
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		opts = {
			enable = true,
			-- Maximum number of lines to show in the context window
			max_lines = 3,
			-- Minimum number of lines to trigger context display
			min_window_height = 10,
			-- Which lines to show:
			-- 'cursor' (default) - lines above cursor
			-- 'topline' - lines above top visible line
			mode = "cursor",
			-- Separator between context and buffer content
			separator = nil,
			-- Z-index of the context window
			zindex = 20,
			-- When to update context
			-- 'line' (default) - on line change
			-- 'char' - on character change
			on_attach = nil,
			-- Trim whitespace from context lines
			trim_scope = "outer",
		},
		keys = {
			{
				"<leader>tsc",
				function()
					require("treesitter-context").toggle()
				end,
				desc = "Toggle Treesitter Context",
			},
			{
				"[c",
				function()
					require("treesitter-context").go_to_context(vim.v.count1)
				end,
				desc = "Jump to Context",
			},
		},

		config = function(_, opts)
			require("treesitter-context").setup(opts)

			-- Custom highlight groups to match your theme
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					-- Set context background to be slightly different from normal background
					vim.api.nvim_set_hl(0, "TreesitterContext", {
						bg = "#2a2a3a", -- Slightly darker background
						fg = "#cdd6f4", -- Catppuccin text color
					})

					-- Context line separator
					vim.api.nvim_set_hl(0, "TreesitterContextSeparator", {
						fg = "#585b70", -- Catppuccin surface2
					})

					-- Bottom border line
					vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", {
						fg = "#6c7086", -- Catppuccin subtext0
						bg = "#2a2a3a",
					})
				end,
			})

			-- Trigger the autocmd for the current colorscheme
			vim.cmd("doautocmd ColorScheme")
		end,
	},
}
