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
		"saghen/blink.nvim",
		lazy = false,
		version = "1.*",
		opts = {
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
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
			"saghen/blink.nvim",
		},
		config = function()
			local util = require("lspconfig.util")
			local lspconfig = require("lspconfig")

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

			-- on-attach goodies (yours unchanged)
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
					map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
					map("]d", vim.diagnostic.goto_next, "Next diagnostic")

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

			-- cache capabilities once
			local caps = (function()
				local c = vim.lsp.protocol.make_client_capabilities()
				local ok, blink = pcall(require, "blink.cmp")
				if ok then
					c = vim.tbl_deep_extend("force", c, blink.get_lsp_capabilities())
				end
				return c
			end)()

			-- ElixirLS via Mason (direct to server script)
			local mason_ls = vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh"

			local servers = {
				clangd = {},
				pyright = {},
				rust_analyzer = {},
				dockerls = {},
				elixirls = {
					cmd = { mason_ls },
					root_dir = util.root_pattern("mix.exs", ".git"),
					settings = { elixirLS = { dialyzerEnabled = false, fetchDeps = false } },
				},
				lua_ls = {
					settings = { Lua = { completion = { callSnippet = "Replace" } } },
				},
			}

			if vim.fn.findfile("Gemfile", ".;") ~= "" then
				servers.ruby_lsp = { root_dir = util.root_pattern("Gemfile") }
			end

			-- actually set up servers
			for name, cfg in pairs(servers) do
				cfg.capabilities = caps
				lspconfig[name].setup(cfg)
			end

			-- tools (formatters/linters) only; NOT servers
			local tools = { "stylua", "prettier", "prettierd", "eslint_d" }
			local ok_mti, mti = pcall(require, "mason-tool-installer")
			if ok_mti then
				mti.setup({ ensure_installed = tools })
			else
				vim.notify("Failed to load mason-tool-installer", vim.log.levels.ERROR)
			end

			-- nushell
			lspconfig.nushell.setup({
				cmd = { "nu", "--lsp" },
				filetypes = { "nu" },
				root_dir = util.root_pattern(".git"),
				capabilities = caps,
			})

			-- if you want mason-lspconfig to also auto-install servers, do it here:
			require("mason-lspconfig").setup({
				ensure_installed = {}, -- e.g. { "pyright", "rust_analyzer" }
				automatic_installation = false, -- you’re setting cmd manually for Elixir
			})
		end,
	},
}
