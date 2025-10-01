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

  -- Core LSP stack (Mason-first)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Optional: speed up Lua module loading
      if vim.fn.has("nvim-0.9") == 1 then
        vim.loader.enable()
      end

      -- Diagnostics UI
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
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- On-attach goodies (your mappings preserved)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("gd", function() require("snacks").picker.lsp_definitions() end,       "Goto Definition")
          map("gr", function() require("snacks").picker.lsp_references() end,        "Goto References")
          map("gI", function() require("snacks").picker.lsp_implementations() end,   "Goto Implementation")
          map("<leader>cr", vim.lsp.buf.rename,                                     "Rename")
          map("<leader>ca", vim.lsp.buf.code_action,                                "Code Action", { "n", "x" })
          map("gD", vim.lsp.buf.declaration,                                        "Goto Declaration")
          map("K",  function() vim.lsp.buf.hover() end,                             "Hover Documentation")
          map("<C-k>", vim.lsp.buf.signature_help,                                  "Signature Documentation")
          map("<leader>Q", vim.diagnostic.open_float,                               "Show line diagnostics")

          local function supports(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
              return client:supports_method(method, bufnr)
            else
              return client:supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local grp = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf, group = grp, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf, group = grp, callback = vim.lsp.buf.clear_references,
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

      -- Capabilities (cmp integration if present)
      local caps = (function()
        local c = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then c = cmp_lsp.default_capabilities(c) end
        return c
      end)()

      -- Mason core
      local ok_mason, mason = pcall(require, "mason")
      if not ok_mason then
        vim.notify("mason not found", vim.log.levels.ERROR)
        return
      end
      mason.setup({})

      -- Keep LSPs + tools installed/up to date
      local ok_mti, mti = pcall(require, "mason-tool-installer")
      if ok_mti then
        mti.setup({
          ensure_installed = {
            -- LSP servers (Mason package IDs or lspconfig names are accepted)
            "lua_ls", "pyright", "rust_analyzer", "dockerls", "jsonls",
            "yamlls", "html", "cssls", "bashls", "gopls", "taplo",
            "elixirls", "graphql", "prismals", "eslint", "tailwindcss",
            -- Formatters / linters / debuggers
            "stylua", "prettier", "prettierd", "eslint_d", "golangci-lint", "delve",
          },
          auto_update = false,
          run_on_start = true,
        })
      else
        vim.notify("mason-tool-installer not found", vim.log.levels.WARN)
      end

      -- mason-lspconfig: install + configure LSP servers
      local ok_mlc, mlc = pcall(require, "mason-lspconfig")
      if not ok_mlc then
        vim.notify("mason-lspconfig not found", vim.log.levels.ERROR)
        return
      end

      mlc.setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "dockerls",
          "jsonls",
          "yamlls",
          "html",
          "cssls",
          "bashls",
          "gopls",
          "taplo",
          "elixirls",
        },
        automatic_installation = true,
      })

      -- Per-server overrides (applied on top of defaults)
      local server_overrides = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              completion = { callSnippet = "Replace" },
              workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true),
              },
            },
          },
        },
        -- Example: add schema support later if you include schemastore.nvim
        -- jsonls = { settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } } },
        -- yamlls = { settings = { yaml = { schemaStore = { enable = true } } } },
      }

      -- Wire everything through lspconfig
      local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
      if not ok_lspconfig then
        vim.notify("nvim-lspconfig not found", vim.log.levels.ERROR)
        return
      end

      mlc.setup({
        ensure_installed = {
          "lua_ls","pyright","rust_analyzer","dockerls","jsonls",
          "yamlls","html","cssls","bashls","gopls","taplo","elixirls",
          -- keep tsserver out if you use pmizio/typescript-tools.nvim
        },
        automatic_installation = true,
        handlers = {
          -- default handler
          function(server_name) default_handler(server_name) end,
          -- per-server handler examples (override defaults if you want)
          -- ["jsonls"] = function() ... end,
        },
      })

      -- Nushell LSP (not in mason-lspconfig by default)
      local nushell_cfg = {
        cmd = { "nu", "--lsp" },
        filetypes = { "nu" },
        root_dir = require("lspconfig.util").root_pattern(".git"),
        capabilities = caps,
      }
      if lspconfig.nushell then
        lspconfig.nushell.setup(nushell_cfg)
      end
    end,
  },
}
