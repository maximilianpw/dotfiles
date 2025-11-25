return {
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		config = function()
			local ok_ts, typescript_tools = pcall(require, "typescript-tools")
			if not ok_ts then
				vim.notify("typescript-tools.nvim not found", vim.log.levels.WARN)
				return
			end

			local function get_capabilities()
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
				if ok then
					capabilities = cmp_lsp.default_capabilities(capabilities)
				end
				return capabilities
			end

			typescript_tools.setup({
				-- Use built-in root_dir pattern detection
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(fname)
				end,
				single_file_support = false,
				capabilities = get_capabilities(),
				handlers = {
					["textDocument/semanticTokens/full"] = function(err, result, ctx, config)
						-- Skip semantic tokens for large files (performance optimization)
						if vim.b.large_file then
							return nil
						end
						return vim.lsp.handlers["textDocument/semanticTokens/full"](err, result, ctx, config)
					end,
				},
				settings = {
					separate_diagnostic_server = true,
					publish_diagnostic_on = "insert_leave",
					expose_as_code_action = "all",
					debounce_text_changes = 300, -- Debounce to reduce server load
					tsserver_file_preferences = {
						includeInlayParameterNameHints = "literals",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = false,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = false,
						includeInlayFunctionLikeReturnTypeHints = false,
						includeInlayEnumMemberValueHints = false,
					},
				},
			})

			-- TypeScript-specific large file handling
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
				callback = function(args)
					local ok, stat = pcall((vim.uv or vim.loop).fs_stat, args.file)
					if ok and stat and stat.size > vim.g.max_file_size * 1024 then
						vim.notify("Large TS file: some LSP features disabled", vim.log.levels.WARN)
						vim.b.large_file = true
						vim.opt_local.syntax = "off"
						vim.diagnostic.enable(false, { bufnr = args.buf })
					end
				end,
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
		"vuki656/package-info.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		ft = "json",
		config = function()
			local ok_pkg, package_info = pcall(require, "package-info")
			if not ok_pkg then
				vim.notify("package-info.nvim not found", vim.log.levels.WARN)
				return
			end

			package_info.setup({
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
	},
}
