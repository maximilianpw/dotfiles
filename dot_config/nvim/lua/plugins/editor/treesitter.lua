-- Treesitter configuration for syntax highlighting
local function should_disable(lang, buf)
	local name = vim.api.nvim_buf_get_name(buf)
	-- 1) Skip any buffer in node_modules or vendor
	if name:match("/node_modules/") or name:match("/vendor/") then
		return true
	end
	-- 2) Skip files over 150 KB (reduced from 200KB for better TS performance)
	local ok, stat = pcall((vim.uv or vim.loop).fs_stat, name)
	if ok and stat and stat.size > 150 * 1024 then
		return true
	end
	-- 3) Skip Ruby indent highlighting if you still want regex indent
	if lang == "ruby" then
		return true
	end
	return false
end

return {
	-- Treesitter core plugin (wrapped in its own table so opts apply correctly)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
			ensure_installed = {
				"bash",
				"c_sharp",
				"css",
				"dockerfile",
				"elixir", "eex", "heex",
				"go", "gomod", "gosum", "gotmpl",
				"html",
				"javascript", "typescript", "tsx",
				"json",
				"lua",
				"markdown",
				"nix",
				"python",
				"rust",
				"toml",
				"vim",
				"yaml",
			},
			auto_install = false,
			sync_install = false,
			ignore_install = { "php" },
			highlight = {
				enable = true,
				disable = should_disable,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = should_disable },
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
		},
	},
	-- Treesitter context companion plugin
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		opts = {
			enable = true,
			max_lines = 3,
			min_window_height = 10,
			mode = "cursor",
			separator = nil,
			zindex = 20,
			on_attach = nil,
			trim_scope = "outer",
			-- Disable context for large files (performance optimization)
			disable = function(_, buf)
				local ok, stat = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
				return ok and stat and stat.size > 150 * 1024
			end,
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
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2a2a3a", fg = "#cdd6f4" })
					vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#585b70" })
					vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#6c7086", bg = "#2a2a3a" })
				end,
			})
			vim.cmd("doautocmd ColorScheme")
		end,
	},
}
