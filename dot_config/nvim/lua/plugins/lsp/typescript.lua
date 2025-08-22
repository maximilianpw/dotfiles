return {
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		config = function()
			local util = require("lspconfig.util")
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
				-- Don't attach in Angular workspaces: nearest package.json must not depend on @angular/core
				root_dir = function(fname)
					local nearest_pkg_dir = util.root_pattern("package.json")(fname)
					if nearest_pkg_dir then
						local pkg_path = nearest_pkg_dir .. "/package.json"
						if vim.fn.filereadable(pkg_path) == 1 then
							local ok_read, lines = pcall(vim.fn.readfile, pkg_path)
							if ok_read and lines then
								local text = table.concat(lines, "\n")
								local decode = (vim.json and vim.json.decode) or vim.fn.json_decode
								local ok_json, pkg = pcall(decode, text)
								if ok_json and pkg then
									local deps = pkg.dependencies or {}
									local dev = pkg.devDependencies or {}
									if deps["@angular/core"] or dev["@angular/core"] then
										-- It's an Angular package: don't attach typescript-tools
										return nil
									end
								end
							end
						end
					end
					return (util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(fname))
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

			-- Add a helper command to restart the typescript-tools client cleanly
			vim.api.nvim_create_user_command("TSToolsRestart", function()
				for _, client in ipairs(vim.lsp.get_active_clients({ name = "typescript-tools" })) do
					client.stop(true)
				end
				vim.defer_fn(function()
					vim.cmd("edit")
				end, 50)
			end, { desc = "Restart typescript-tools LSP client" })
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
}
