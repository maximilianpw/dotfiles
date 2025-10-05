--[[
  LSP Configuration - Hybrid Setup (Mason on macOS, System LSPs on NixOS)

  ADDING A NEW LANGUAGE:

  1. NixOS Setup (required on NixOS):
     - Add the LSP package to ~/nix-config/users/maxpw/neovim.nix
     - Example: pkgs.nodePackages.typescript-language-server
     - Run: sudo nixos-rebuild switch

  2. Neovim Config (required on both platforms):
     - Add the server name to the `ensure_servers` list below (around line 161)
     - Example: "tsserver" for TypeScript
     - Optional: Add server-specific settings to `server_overrides` (around line 181)

  3. macOS Only:
     - Mason will automatically install the LSP when you restart Neovim
     - No additional steps needed

  Server names reference: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--]]

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

  -- Core LSP stack (Hybrid: Mason on macOS, system LSPs on NixOS)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Conditionally load Mason only on non-NixOS systems
      {
        "williamboman/mason.nvim",
        cond = function()
          return vim.fn.filereadable("/etc/NIXOS") ~= 1
        end,
        opts = {}
      },
      {
        "williamboman/mason-lspconfig.nvim",
        cond = function()
          return vim.fn.filereadable("/etc/NIXOS") ~= 1
        end,
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        cond = function()
          return vim.fn.filereadable("/etc/NIXOS") ~= 1
        end,
      },
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Platform detection
      local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1

      -- Optional: speed up Lua module loading
      if vim.fn.has("nvim-0.9") == 1 then
        vim.loader.enable()
      end

      -- Diagnostics UI
      local diag_signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(diag_signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
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
        signs = { severity = { min = vim.diagnostic.severity.HINT } },
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
          local has_snacks, snacks = pcall(require, "snacks")
          local function picker(name, fallback)
            if has_snacks and snacks.picker and snacks.picker[name] then
              return function() snacks.picker[name]() end
            end
            return fallback
          end

          map("gd", picker("lsp_definitions", vim.lsp.buf.definition),            "Goto Definition")
          map("gr", picker("lsp_references", vim.lsp.buf.references),             "Goto References")
          map("gI", picker("lsp_implementations", vim.lsp.buf.implementation),    "Goto Implementation")
          map("<leader>cr", vim.lsp.buf.rename,                                     "Rename")
          map("<leader>ca", vim.lsp.buf.code_action,                                "Code Action", { "n", "x" })
          map("gD", vim.lsp.buf.declaration,                                        "Goto Declaration")
          map("K",  function() vim.lsp.buf.hover() end,                             "Hover Documentation")
          map("<C-k>", vim.lsp.buf.signature_help,                                  "Signature Documentation")
          map("<leader>Q", vim.diagnostic.open_float,                               "Show line diagnostics")
          map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end,    "Format Document")

          if vim.lsp.inlay_hint and (vim.lsp.inlay_hint.is_enabled or vim.fn.has("nvim-0.10") == 1) then
            map("<leader>ci", function()
              local ih = vim.lsp.inlay_hint
              if type(ih) == "table" and ih.is_enabled and ih.enable then
                local enabled = false
                local ok, res = pcall(ih.is_enabled, ih, event.buf)
                if not ok then
                  ok, res = pcall(ih.is_enabled, ih, { bufnr = event.buf })
                end
                if ok then enabled = res end
                local ok_enable = pcall(ih.enable, ih, event.buf, not enabled)
                if not ok_enable then
                  pcall(ih.enable, ih, { bufnr = event.buf, enabled = not enabled })
                end
              elseif type(ih) == "function" then
                local enabled = ih.is_enabled and ih.is_enabled(event.buf)
                ih(event.buf, not enabled)
              end
            end, "Toggle Inlay Hints")
          end

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
      local function get_capabilities()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then
          capabilities = cmp_lsp.default_capabilities(capabilities)
        end
        return capabilities
      end

      local caps = get_capabilities()

      -- LSP servers list (shared between Mason and NixOS)
      local ensure_servers = {
        "bashls",
        "cssls",
        "dockerls",
        "elixirls",
        "eslint",
        "gopls",
        "graphql",
        "html",
        "jsonls",
        "lua_ls",
        "prismals",
        "pyright",
        "rust_analyzer",
        "tailwindcss",
        "taplo",
        "yamlls",
      }

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

      -- Wire everything through lspconfig (nvim 0.11+ compatible)
      local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
      if not ok_lspconfig then
        vim.notify("nvim-lspconfig not found", vim.log.levels.ERROR)
        return
      end

      local util = lspconfig.util or require("lspconfig.util")

      local function default_handler(server_name)
        -- Check if nvim 0.11+ to use vim.lsp.config API
        if vim.fn.has("nvim-0.11") == 1 and vim.lsp.config and vim.lsp.config[server_name] then
          local override = server_overrides[server_name]
          if type(override) == "function" then
            override = override()
          end
          local opts = vim.tbl_deep_extend("force", { capabilities = vim.deepcopy(caps) }, override or {})
          -- Use new API for nvim 0.11+
          vim.lsp.enable(server_name, opts)
        else
          -- Fallback to lspconfig for nvim < 0.11
          if not lspconfig[server_name] then
            vim.notify(string.format("lspconfig missing server %s", server_name), vim.log.levels.WARN)
            return
          end

          local override = server_overrides[server_name]
          if type(override) == "function" then
            override = override()
          end

          local opts = vim.tbl_deep_extend("force", { capabilities = vim.deepcopy(caps) }, override or {})
          lspconfig[server_name].setup(opts)
        end
      end

      -- HYBRID SETUP: Mason on macOS, system LSPs on NixOS
      if is_nixos then
        -- On NixOS: use system-provided LSPs
        vim.notify("NixOS detected: using system LSPs", vim.log.levels.INFO)
        for _, server_name in ipairs(ensure_servers) do
          default_handler(server_name)
        end
      else
        -- On macOS/other: use Mason to manage LSPs
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
            ensure_installed = vim.list_extend(vim.deepcopy(ensure_servers), {
              -- Formatters / linters / debuggers
              "delve",
              "eslint_d",
              "golangci-lint",
              "prettier",
              "prettierd",
              "stylua",
            }),
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
          ensure_installed = ensure_servers,
          automatic_installation = true,
          handlers = { default_handler },
        })
      end

      -- Nushell LSP (not in mason-lspconfig by default)
      local nushell_cfg = {
        cmd = { "nu", "--lsp" },
        filetypes = { "nu" },
        root_dir = util.root_pattern(".git"),
        capabilities = vim.deepcopy(caps),
      }
      if vim.fn.has("nvim-0.11") == 1 and vim.lsp.config and vim.lsp.config.nushell then
        vim.lsp.enable("nushell", nushell_cfg)
      elseif lspconfig.nushell then
        lspconfig.nushell.setup(nushell_cfg)
      end
    end,
  },
}
