return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			if vim.fn.has("nvim-0.9") == 1 then
				vim.loader.enable()
			end

			-- diagnostics UI
			vim.diagnostic.config({
				virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
				float = {
					source = "always",
					border = "rounded",
					header = "",
					prefix = "",
					format = function(d)
						local sev = vim.diagnostic.severity[d.severity]
						return string.format("%s [%s] %s", sev, d.source or "LSP", d.message)
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

			-- on-attach goodies
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("gd", function()
						require("snacks").picker.lsp_definitions()
					end, "Goto Definition")
					map("gr", function()
						require("snacks").picker.lsp_references()
					end, "Goto References")
					map("gI", function()
						require("snacks").picker.lsp_implementations()
					end, "Goto Implementation")
					map("<leader>cr", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("K", function()
						vim.lsp.buf.hover()
					end, "Hover Documentation")
					map("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
					map("<leader>Q", vim.diagnostic.open_float, "Show line diagnostics")

					local function supports(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client:supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client and supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
					then
						local grp = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = grp,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = grp,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(ev)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = ev.buf })
							end,
						})
					end
				end,
			})

			-- capabilities
			local caps = (function()
				local c = vim.lsp.protocol.make_client_capabilities()
				local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
				if ok then
					c = cmp_lsp.default_capabilities(c)
				end
				return c
			end)()

			-- Helper function to check if executable exists
			local function executable_exists(name)
				return vim.fn.executable(name) == 1
			end

			-- Mason paths / helpers
			local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
			local mason_ls = vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh"

			-- Define servers ONCE - only include servers that are available
			local servers = {}

			-- Only add servers if their executables exist
			if executable_exists("clangd") then
				servers.clangd = { cmd = { "clangd" } }
			end

			-- Check for Mason-installed or system pyright
			if vim.fn.filereadable(mason_bin .. "/pyright-langserver") == 1 then
				servers.pyright = { cmd = { mason_bin .. "/pyright-langserver", "--stdio" } }
			elseif executable_exists("pyright-langserver") then
				servers.pyright = { cmd = { "pyright-langserver", "--stdio" } }
			end

			if executable_exists("rust-analyzer") then
				servers.rust_analyzer = { cmd = { "rust-analyzer" } }
			end

			-- Check for Mason-installed or system docker-langserver
			if vim.fn.filereadable(mason_bin .. "/docker-langserver") == 1 then
				servers.dockerls = { cmd = { mason_bin .. "/docker-langserver", "--stdio" } }
			elseif executable_exists("docker-langserver") then
				servers.dockerls = { cmd = { "docker-langserver", "--stdio" } }
			end

			-- Check for Elixir LS
			if vim.fn.filereadable(mason_ls) == 1 then
				servers.elixirls = {
					cmd = { mason_ls },
					root_markers = { "mix.exs", ".git" },
					settings = { elixirLS = { dialyzerEnabled = false, fetchDeps = false } },
				}
			end

			-- Check for Mason-installed or system lua-language-server
			if vim.fn.filereadable(mason_bin .. "/lua-language-server") == 1 then
				servers.lua_ls = {
					cmd = { mason_bin .. "/lua-language-server" },
					settings = { Lua = { completion = { callSnippet = "Replace" } } },
				}
			elseif executable_exists("lua-language-server") then
				servers.lua_ls = {
					cmd = { "lua-language-server" },
					settings = { Lua = { completion = { callSnippet = "Replace" } } },
				}
			end

			if vim.fn.findfile("Gemfile", ".;") ~= "" then
				servers.ruby_lsp = { root_markers = { "Gemfile" } }
			end

			local is_new = vim.fn.has("nvim-0.11") == 1 and vim.lsp and vim.lsp.config and vim.lsp.enable

			if is_new then
				--  New API: register + enable, no lspconfig required
				for name, cfg in pairs(servers) do
					local cfg_with_caps = vim.tbl_deep_extend("force", { capabilities = caps }, cfg)
					vim.lsp.config(name, cfg_with_caps)
					vim.lsp.enable(name)
				end
			else
				--  Legacy fallback for < 0.11
				local util = require("lspconfig.util")
				local lspconfig = require("lspconfig")

				-- Map root_markers -> root_dir when needed
				for name, cfg in pairs(servers) do
					if cfg.root_markers and not cfg.root_dir then
						cfg.root_dir = util.root_pattern(unpack(cfg.root_markers))
					end
					cfg.capabilities = caps
					lspconfig[name].setup(cfg)
				end
			end

			-- tools (formatters/linters/debuggers) only; NOT servers
			local tools = { "stylua", "prettier", "prettierd", "eslint_d", "golangci-lint", "delve" }
			local ok_mti, mti = pcall(require, "mason-tool-installer")
			if ok_mti then
				mti.setup({ ensure_installed = tools })
			else
				vim.notify("Failed to load mason-tool-installer", vim.log.levels.ERROR)
			end

			-- Nushell example (same pattern as above)
			local nushell_cfg = {
				cmd = { "nu", "--lsp" },
				filetypes = { "nu" },
				root_markers = { ".git" },
				capabilities = caps,
			}

			if is_new then
				vim.lsp.config("nushell", nushell_cfg)
				vim.lsp.enable("nushell")
			else
				local util = require("lspconfig.util")
				nushell_cfg.root_dir = util.root_pattern(".git")
				require("lspconfig").nushell.setup(nushell_cfg)
			end

			-- mason-lspconfig (auto-install language servers)
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright", 
					"dockerls",
					"elixirls"
				},
				automatic_installation = true,
			})
		end,
	},
}
