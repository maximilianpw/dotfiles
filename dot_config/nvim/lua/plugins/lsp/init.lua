return {
	-- Lua dev ergonomics (luv/vim types for better completion)
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Fidget for LSP progress
	{ "j-hui/fidget.nvim", opts = {} },

	-- Native LSP setup (loaded via lazy.nvim's config mechanism)
	{
		dir = vim.fn.stdpath("config"),
		name = "native-lsp-setup",
		config = function()
			-- Speed up Lua module loading
			if vim.loader then
				vim.loader.enable()
			end

			-- Diagnostics UI
			local diag_signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(diag_signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			vim.diagnostic.config({
				virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
				float = {
					source = true,
					border = "rounded",
					header = "",
					prefix = "",
				},
				signs = { severity = { min = vim.diagnostic.severity.HINT } },
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- Inject schemastore schemas into jsonls/yamlls
			local ok_schema, schemastore = pcall(require, "schemastore")
			if ok_schema then
				vim.lsp.config("jsonls", {
					settings = {
						json = {
							schemas = schemastore.json.schemas(),
						},
					},
				})
				vim.lsp.config("yamlls", {
					settings = {
						yaml = {
							schemas = schemastore.yaml.schemas(),
						},
					},
				})
			end

			-- Enable all LSP servers (configs loaded from lsp/ directory)
			-- Note: gopls is managed by go.nvim, rust-analyzer by rustaceanvim
			local servers = {
				"bashls",
				"cssls",
				"dockerls",
				"eslint",
				"html",
				"jsonls",
				"lua_ls",
				"nushell",
				"omnisharp",
				"pyright",
				"tailwindcss",
				"taplo",
				"yamlls",
			}
			vim.lsp.enable(servers)

			-- LspAttach autocmd for keybindings and native completion
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("native-lsp-attach", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					local bufnr = event.buf

					-- Enable native completion for this buffer
					if client and client:supports_method("textDocument/completion") then
						vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
					end

					-- Keymaps
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end

					local has_snacks, snacks = pcall(require, "snacks")
					local function picker(name, fallback)
						if has_snacks and snacks.picker and snacks.picker[name] then
							return function()
								snacks.picker[name]()
							end
						end
						return fallback
					end

					map("gd", picker("lsp_definitions", vim.lsp.buf.definition), "Goto Definition")
					map("gr", picker("lsp_references", vim.lsp.buf.references), "Goto References")
					map("gI", picker("lsp_implementations", vim.lsp.buf.implementation), "Goto Implementation")
					map("gt", picker("lsp_type_definitions", vim.lsp.buf.type_definition), "Goto Type Definition")
					map("<leader>cr", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
					map("<leader>Q", vim.diagnostic.open_float, "Show line diagnostics")
					map("<leader>cf", function()
						vim.lsp.buf.format({ async = true })
					end, "Format Document")

					-- Inlay hints toggle
					if vim.lsp.inlay_hint then
						map("<leader>ci", function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
								{ bufnr = bufnr }
							)
						end, "Toggle Inlay Hints")
					end

					-- ESLint auto-fix on save
					if client and client.name == "eslint" then
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "LspEslintFixAll",
						})
					end

					-- Skip document highlighting for large files
					if vim.b.large_file then
						return
					end

					-- Document highlight on cursor hold
					if client and client:supports_method("textDocument/documentHighlight") then
						local grp = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						local highlight_timer = nil

						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = bufnr,
							group = grp,
							callback = function()
								if highlight_timer then
									highlight_timer:stop()
								end
								highlight_timer = (vim.uv or vim.loop).new_timer()
								highlight_timer:start(100, 0, function()
									vim.schedule(function()
										vim.lsp.buf.document_highlight()
									end)
								end)
							end,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = bufnr,
							group = grp,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(ev)
								if highlight_timer then
									highlight_timer:stop()
								end
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
							end,
						})
					end
				end,
			})
		end,
	},
}
