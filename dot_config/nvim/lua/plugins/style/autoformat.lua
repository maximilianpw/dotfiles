return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer (Conform)",
    },
  },
  opts = function()
    local fs = require("util.fs")
    local tooling = require("util.tooling")

    local prettier_ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "css",
      "scss",
      "less",
      "html",
      "json",
      "jsonc",
      "yaml",
      "markdown",
      "graphql",
    }

    -- Filetypes biome can format (subset of prettier_ft)
    local biome_ft = {
      javascript = true,
      javascriptreact = true,
      typescript = true,
      typescriptreact = true,
      vue = true,
      css = true,
      json = true,
      jsonc = true,
      graphql = true,
    }

    -- Config presence checks, repository-scoped (never walk above the VCS root).
    local function has_prettier_config(bufnr)
      return fs.has_config(bufnr, tooling.prettier)
    end

    local function has_biome_config(bufnr)
      return fs.has_config(bufnr, tooling.biome)
    end

    local function has_eslint_config(bufnr)
      return fs.has_config(bufnr, tooling.eslint)
    end

    local formatters_by_ft = {
      lua = { "stylua" },
      nix = { "alejandra" },
      elixir = { "lsp" },
      heex = { "lsp" },
      eex = { "lsp" },
      go = { "goimports", "gofmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      rust = { "rustfmt" },
      terraform = { "terraform_fmt" },
      python = { "ruff_format", "black", stop_after_first = true },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      toml = { "taplo" },
      zig = { "zigfmt" },
    }

    local prettier_formatters = { "prettierd", "prettier", stop_after_first = true }
    local biome_formatters = { "biome", "prettierd", "prettier", stop_after_first = true }

    -- Prettier-eligible filetypes use LSP fallback; biome wins only in projects with a biome config
    for _, ft in ipairs(prettier_ft) do
      if biome_ft[ft] then
        formatters_by_ft[ft] = function(bufnr)
          if has_biome_config(bufnr) then
            return biome_formatters
          end
          if has_prettier_config(bufnr) then
            return prettier_formatters
          end
          return {}
        end
      else
        formatters_by_ft[ft] = function(bufnr)
          if has_prettier_config(bufnr) then
            return prettier_formatters
          end

          return {}
        end
      end
    end

    return {
      notify_on_error = true,

      format_on_save = function(bufnr)
        if _G.is_bigfile and _G.is_bigfile(bufnr, "huge") then
          return nil
        end

        local ft = vim.bo[bufnr].filetype

        -- Skip prettier/biome filetypes entirely when the project has no formatter config.
        -- Do not fall back to tsserver/html/css LSP formatting: it ignores project Prettier
        -- ownership and can apply editor/default style or ~/.prettierrc.
        if vim.tbl_contains(prettier_ft, ft) then
          if not has_prettier_config(bufnr) and not has_biome_config(bufnr) then
            return {
              timeout_ms = 2000,
              lsp_format = has_eslint_config(bufnr) and "fallback" or "never",
              formatters = {},
            }
          end

          local formatters = has_biome_config(bufnr) and { "biome", "prettierd", "prettier" }
            or { "prettierd", "prettier" }

          return {
            timeout_ms = 2000,
            lsp_format = "never",
            formatters = formatters,
            stop_after_first = true,
          }
        end

        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt = disable_filetypes[ft] and "never" or "fallback"

        return {
          timeout_ms = 2000,
          lsp_format = lsp_format_opt,
        }
      end,

      formatters_by_ft = formatters_by_ft,
    }
  end,
}
