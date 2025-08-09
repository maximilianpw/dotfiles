-- Neovim 0.8+ check helper
local has_nvim, nvim_version = pcall(vim.fn.has, "nvim-0.8")
local is_modern = has_nvim and nvim_version == 1

return {
	{
		"hrsh7th/nvim-cmp",
		cond = function()
			return is_modern
		end,
		event = "InsertEnter",
		dependencies = {
			-- Snippet engine: define and expand code snippets on demand
			{ "L3MON4D3/LuaSnip", lazy = true },
			-- A large, ready-to-use snippet collection for LuaSnip
			{ "rafamadriz/friendly-snippets", lazy = true },
			-- Bridges LuaSnip snippets into the nvim-cmp completion menu
			"saadparwaiz1/cmp_luasnip",
			-- Adds pictograms (icons) and annotation text to completion items
			"onsails/lspkind-nvim",
			-- Source for language server protocol (LSP) completions
			"hrsh7th/cmp-nvim-lsp",
			-- Source for filesystem path completions (e.g. require(), :edit)
			"hrsh7th/cmp-path",
			-- Source for LSP signature help (function signatures) in the completion menu
			"hrsh7th/cmp-nvim-lsp-signature-help",
			-- Source for buffer-based completions (words from open buffers)
			"hrsh7th/cmp-buffer",
			-- Source for on-the-fly calculator results (e.g. =2*3 → 6)
			"hrsh7th/cmp-calc",
		},
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
					preselect = "none",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping.confirm({ select = false }),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = require("lspkind").cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
						menu = {
							buffer = "[Buf]",
							nvim_lsp = "[LSP]",
							luasnip = "[Snip]",
							path = "[Path]",
							calc = "[Calc]",
							nvim_lsp_signature_help = "[Sig]",
						},
					}),
				},
				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						cmp.config.compare.kind,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				experimental = {
					ghost_text = {
						hl_group = "Comment",
						only_current_line = true,
					},
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "calc" },
				}, {
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
				}),
			}
		end,
	},
}
