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
    -- Prettier config file names (https://prettier.io/docs/en/configuration)
    local prettier_configs = {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.json5",
      ".prettierrc.js",
      ".prettierrc.cjs",
      ".prettierrc.mjs",
      ".prettierrc.toml",
      "prettier.config.js",
      "prettier.config.cjs",
      "prettier.config.mjs",
    }

    local prettier_ft = {
      "javascript", "javascriptreact", "typescript", "typescriptreact",
      "vue", "css", "scss", "less", "html",
      "json", "jsonc", "yaml", "markdown", "graphql",
    }

    --- Check if the project has a prettier config
    local function has_prettier_config(bufnr)
      local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
      return #vim.fs.find(prettier_configs, { upward = true, path = buf_dir }) > 0
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
    }

    -- Prettier-eligible filetypes use LSP fallback; prettier is injected dynamically
    for _, ft in ipairs(prettier_ft) do
      formatters_by_ft[ft] = { "prettierd", "prettier", stop_after_first = true }
    end

    return {
      notify_on_error = true,

      format_on_save = function(bufnr)
        if vim.b[bufnr].bigfile_level == "huge" then
          return nil
        end

        local ft = vim.bo[bufnr].filetype

        -- Skip prettier for filetypes that support it when no config is present
        if vim.tbl_contains(prettier_ft, ft) and not has_prettier_config(bufnr) then
          return {
            timeout_ms = 2000,
            lsp_format = "fallback",
            formatters = {},
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
