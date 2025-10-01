return {
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		config = function()
			local util = require("lspconfig.util")
			-- Get capabilities for blink.cmp integration
			local function get_capabilities()
				local c = vim.lsp.protocol.make_client_capabilities()
				local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
				if ok then
					c = cmp_lsp.default_capabilities(c)
				end
				return c
			end

			require("typescript-tools").setup({
				root_dir = function(fname)
					return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(fname)
				end,
				single_file_support = false,
				capabilities = get_capabilities(),
				settings = {
					-- Optimize performance
					separate_diagnostic_server = true,
					publish_diagnostic_on = "insert_leave",
					-- Ensure proper TypeScript/JavaScript file handling
					expose_as_code_action = "all",
					tsserver_file_preferences = {
						-- Disable inlay hints to prevent errors
						includeInlayParameterNameHints = "none",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = false,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = false,
						includeInlayFunctionLikeReturnTypeHints = false,
						includeInlayEnumMemberValueHints = false,
					},
				},
			})
		end,
	},
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"dmmulroy/ts-error-translator.nvim",
		ft = { "typescript", "typescriptreact" },
		opts = {},
	},
	{
		-- Package.json management
		"vuki656/package-info.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		ft = "json",
		config = function()
			require("package-info").setup({
				colors = {
					up_to_date = "#3C4048",
					outdated = "#fc514e",
				},
				icons = {
					enable = true,
					style = {
						up_to_date = "|  ",
						outdated = "|  ",
					},
				},
				autostart = true,
				hide_up_to_date = false,
				hide_unstable_versions = false,
			})
		end,
	}
}
