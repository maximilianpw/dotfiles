-- Neovim 0.8+ check helper
local has_nvim, nvim_version = pcall(vim.fn.has, 'nvim-0.8')
local is_modern = has_nvim and nvim_version == 1

return {
  -- Completion engine
  {
    'hrsh7th/nvim-cmp',
    cond = function()
      return is_modern
    end,
    event = 'InsertEnter',
    dependencies = {
      { 'L3MON4D3/LuaSnip', lazy = true },
      { 'rafamadriz/friendly-snippets', lazy = true },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'onsails/lspkind-nvim',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-calc',
    },
    opts = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      return {
        completion = {
          completeopt = 'menu,menuone,noinsert',
          preselect = 'none',
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = false },
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<C-Space>'] = cmp.mapping.complete(),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = require('lspkind').cmp_format {
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
            menu = {
              buffer = '[Buf]',
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              path = '[Path]',
              calc = '[Calc]',
              nvim_lsp_signature_help = '[Sig]',
            },
          },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require('cmp-under-comparator').under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        experimental = {
          ghost_text = {
            hl_group = 'Comment',
            only_current_line = true,
          },
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'calc' },
        }, {
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        }),
      }
    end,
  },

  -- Automatic bracket/quote pairing
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local npairs = require 'nvim-autopairs'
      npairs.setup {
        check_ts = true,
        enable_check_bracket_line = false,
        map_cr = true,
        disable_filetype = { 'TelescopePrompt', 'vim' },
        fast_wrap = { map = '<M-e>', offset = 0, end_key = '$', keys = 'qwertyuiop[]' },
        ts_config = {
          lua = { 'string' },
          javascript = { 'template_string' },
        },
      }
      -- integrate with cmp
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
}
