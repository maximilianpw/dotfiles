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

  -- Fidget for LSP progress (lazy-loaded on LSP attach)
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },

  -- Native LSP configuration
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      -- Diagnostics UI
      local diag_signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(diag_signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
          severity = { min = vim.diagnostic.severity.WARN }, -- Only show warnings+
        },
        float = {
          source = true,
          border = "rounded",
          header = "",
          prefix = "",
          focusable = true, -- Allow interacting with diagnostic floats
          max_width = 80,
        },
        signs = {
          severity = { min = vim.diagnostic.severity.HINT },
          priority = 20, -- Show diagnostics above other signs
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        jump = { float = true }, -- Show float when jumping to diagnostic
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
      -- Note: rust-analyzer is managed by rustaceanvim
      local servers = {
        "bashls",
        "cssls",
        "dockerls",
        "eslint",
        "gopls",
        "html",
        "jsonls",
        "lua_ls",
        "nushell",
        "tailwindcss",
        "taplo",
        "yamlls",
      }
      vim.lsp.enable(servers)

      -- Create augroups once
      local lsp_highlight_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })
      local lsp_detach_group = vim.api.nvim_create_augroup("lsp-detach", { clear = true })

      -- Helper function to format buffer with conform fallback to LSP
      local function format_buffer()
        local has_conform, conform = pcall(require, "conform")
        if has_conform then
          conform.format({ async = true, lsp_format = "fallback" })
        else
          vim.lsp.buf.format({ async = true })
        end
      end

      -- LspAttach autocmd for keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("native-lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          local bufnr = event.buf

          -- Enable completion triggered by <c-x><c-o>
          vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

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
          map("<leader>cs", vim.lsp.buf.signature_help, "Signature Documentation")
          map("<leader>Q", vim.diagnostic.open_float, "Show line diagnostics")
          map("<leader>cf", format_buffer, "Format Document")

          -- Inlay hints toggle
          if vim.lsp.inlay_hint then
            map("<leader>ci", function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                { bufnr = bufnr }
              )
            end, "Toggle Inlay Hints")
          end

          -- Skip document highlighting for large files
          if vim.b[bufnr].bigfile then
            return
          end

          -- Document highlight on cursor hold (using vim.defer_fn instead of uv timers)
          if client and client:supports_method("textDocument/documentHighlight") then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = lsp_highlight_group,
              buffer = bufnr,
              callback = function()
                vim.defer_fn(function()
                  if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
                    pcall(vim.lsp.buf.document_highlight)
                  end
                end, 100)
              end,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = lsp_highlight_group,
              buffer = bufnr,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = lsp_detach_group,
              buffer = bufnr,
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = lsp_highlight_group, buffer = ev.buf })
              end,
            })
          end
        end,
      })
    end,
  },
}
