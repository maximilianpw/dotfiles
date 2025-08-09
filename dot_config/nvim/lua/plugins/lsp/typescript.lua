return {
	{
		'pmizio/typescript-tools.nvim',
		dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
		ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
		config = function()
			-- Get capabilities for blink.cmp integration
			local function get_capabilities()
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				local ok, blink = pcall(require, "blink.cmp")
				if ok then
					capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
				end
				return capabilities
			end
			
			require("typescript-tools").setup({
				capabilities = get_capabilities(),
				settings = {
					-- Optimize performance
					separate_diagnostic_server = true,
					publish_diagnostic_on = "insert_leave",
					-- Ensure proper TypeScript/JavaScript file handling
					expose_as_code_action = "all",
					tsserver_file_preferences = {
						-- Improve IntelliSense
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			})
		end,
	},
	{
		'folke/ts-comments.nvim',
		event = 'VeryLazy',
		opts = {},
	},
	{
		'dmmulroy/ts-error-translator.nvim',
		ft = { 'typescript', 'typescriptreact' },
		opts = {},
	},
}
