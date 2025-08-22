local util = require("lspconfig.util")
return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{ -- blink completion with lazydev integration
		"saghen/blink.nvim",
		lazy = false,
		version = "1.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			sources = {
				-- Add lazydev to the default sources for Lua development
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- Prioritize lazydev suggestions
					},
				},
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Mason must be loaded before its dependents so we need to set it up here.
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Completion capabilities provided by blink.cmp
			"saghen/blink.nvim",
		},
		config = function()
			-- Enable faster module loading in Neovim 0.9+
			if vim.fn.has("nvim-0.9") == 1 then
				vim.loader.enable()
			end

			-- Configure diagnostic display
			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●", -- Could be '■', '▎', 'x', '●'
				},
				float = {
					source = "always", -- Or "if_many"
					border = "rounded",
					header = "",
					prefix = "",
					format = function(diagnostic)
						local severity = vim.diagnostic.severity[diagnostic.severity]
						return string.format("%s [%s] %s", severity, diagnostic.source or "LSP", diagnostic.message)
					end,
				},
				signs = {
					severity = { min = vim.diagnostic.severity.HINT },
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = " ",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					--  To jump back, press <C-t>.
					map("gd", function()
						require("snacks").picker.lsp_definitions()
					end, "Goto Definition")

					-- Find references for the word under your cursor.
					map("gr", function()
						require("snacks").picker.lsp_references()
					end, "Goto References")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", function()
						require("snacks").picker.lsp_implementations()
					end, "Goto Implementation")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>cr", vim.lsp.buf.rename, "Rename")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })

					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")

					-- Show hover information (documentation, type info, errors)
					-- Prefer Angular LS in Angular projects, otherwise typescript-tools
					map("K", function()
						local clients = vim.lsp.get_clients({ bufnr = event.buf })
						local preferred = nil
						for _, client in ipairs(clients) do
							if client.name == "angularls" then
								preferred = client
								break
							end
						end
						if not preferred then
							for _, client in ipairs(clients) do
								if client.name == "typescript-tools" then
									preferred = client
									break
								end
							end
						end

						if preferred then
							local params = vim.lsp.util.make_position_params()
							preferred.request("textDocument/hover", params, function(err, result)
								if err then
									vim.notify("Hover error: " .. vim.inspect(err), vim.log.levels.ERROR)
									return
								end

								if result and result.contents then
									local contents = result.contents
									local lines = {}

									if type(contents) == "table" then
										for _, content in ipairs(contents) do
											if type(content) == "string" and content ~= "" then
												table.insert(lines, content)
											elseif type(content) == "table" and content.value then
												table.insert(lines, content.value)
											end
										end
									elseif type(contents) == "string" then
										lines = { contents }
									end

									if #lines > 0 then
										vim.lsp.util.open_floating_preview(lines, "markdown", {
											border = "rounded",
											max_width = 80,
											max_height = 20,
											focusable = false,
										})
									end
								end
							end, event.buf)
						else
							vim.lsp.buf.hover()
						end
					end, "Hover Documentation")

					-- Show signature help when inside function parameters
					map("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

					-- Open diagnostic float (show error details)
					map("<leader>Q", vim.diagnostic.open_float, "Show line diagnostics")

					-- Navigate between diagnostics
					map("[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
					map("]d", vim.diagnostic.goto_next, "Go to next diagnostic")

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client:supports_method(method, { bufnr = bufnr })
						end
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end
				end,
			})

			-- Function to get capabilities with blink.cmp integration
			local function get_capabilities()
				local capabilities = vim.lsp.protocol.make_client_capabilities()

				-- Add blink.cmp capabilities if available
				local ok, blink = pcall(require, "blink.cmp")
				if ok then
					capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
				end

				return capabilities
			end

			-- add more lsp servers
			local servers = {
				clangd = {},
				pyright = {},
				rust_analyzer = {},
				dockerls = {},
				tailwindcss = {},
				angularls = {
					-- Attach only when the nearest package depends on Angular and there's an angular.json up the tree
					root_dir = function(fname)
						local nearest_pkg_dir = util.root_pattern("package.json")(fname)
						if not nearest_pkg_dir then
							return nil
						end
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
										local workspace_root = util.root_pattern("angular.json")(fname)
										if workspace_root then
											return workspace_root
										end
									end
								end
							end
						end
						return nil
					end,
					single_file_support = false,
					filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
				},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			}

			-- Conditionally add Ruby LSP only if Gemfile exists in current working directory or project
			if vim.fn.findfile("Gemfile", ".;") ~= "" then
				servers.ruby_lsp = {
					root_dir = util.root_pattern("Gemfile"),
				}
			end

			-- Set up each server with capabilities
			local lspconfig = require("lspconfig")
			for name, cfg in pairs(servers) do
				cfg = vim.tbl_deep_extend("force", { capabilities = get_capabilities() }, cfg)
				lspconfig[name].setup(cfg)
			end

			-- Add other tools here that you want Mason to install
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"prettier", -- Used to format JavaScript/TypeScript code
				"prettierd", -- Faster prettier daemon
				"eslint_d", -- Faster version of eslint
				"angular-language-server", -- Ensure Angular LS is installed by Mason
			})

			-- Error handling for Mason Tool Installer
			local ok, mason_tool_installer = pcall(require, "mason-tool-installer")
			if ok then
				mason_tool_installer.setup({ ensure_installed = ensure_installed })
			else
				vim.notify("Failed to load mason-tool-installer", vim.log.levels.ERROR)
			end

			require("lspconfig").nushell.setup({
				cmd = { "nu", "--lsp" },
				filetypes = { "nu" },
				root_dir = util.root_pattern(".git", vim.fn.getcwd()),
				capabilities = get_capabilities(),
			})
			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
			})
		end,
	},
}
