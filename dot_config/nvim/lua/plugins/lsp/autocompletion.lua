local is_modern = vim.fn.has("nvim-0.8") == 1

return {
  {
    "hrsh7th/nvim-cmp",
    cond = function()
      return is_modern
    end,
    enabled = function()
      -- Disable completion for large files (performance optimization)
      local ok, stat = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(0))
      if ok and stat and stat.size > 150 * 1024 then
        return false
      end
      return true
    end,
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip", lazy = true },
      { "rafamadriz/friendly-snippets", lazy = true },
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-calc",
    },
    opts = function()
      local ok_cmp, cmp = pcall(require, "cmp")
      if not ok_cmp then
        vim.notify("nvim-cmp not found", vim.log.levels.WARN)
        return {}
      end

      local ok_snip, luasnip = pcall(require, "luasnip")
      if not ok_snip then
        vim.notify("LuaSnip not found", vim.log.levels.WARN)
        return {}
      end

      local ok_loader, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
      if ok_loader then
        vscode_loader.lazy_load()
      end

      local ok_lspkind, lspkind = pcall(require, "lspkind")

      local function has_words_before()
        local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        if col == 0 then
          return false
        end
        local current = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        return current:sub(col, col):match("%s") == nil
      end

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
          preselect = cmp.PreselectMode.None,
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
            elseif has_words_before() then
              cmp.complete()
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
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = false }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = ok_lspkind and {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 60,
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
        } or nil,
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
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
