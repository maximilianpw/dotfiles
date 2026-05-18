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

    -- Filetypes biome can format (subset of prettier_ft)
    local biome_ft = {
      javascript = true, javascriptreact = true,
      typescript = true, typescriptreact = true,
      vue = true, css = true,
      json = true, jsonc = true, graphql = true,
    }

    local function project_root(buf_dir)
      -- Use the nearest package boundary before falling back to VCS root. This keeps
      -- nested packages (for example backend/packages/types) from inheriting a
      -- parent repo's Prettier config when that package does not define one.
      return vim.fs.root(buf_dir, { "package.json", ".git", ".jj" }) or buf_dir
    end

    local function find_upward_until(names, start_dir, stop_dir)
      local dir = start_dir
      while dir and dir ~= "" do
        for _, name in ipairs(names) do
          local candidate = vim.fs.joinpath(dir, name)
          if vim.uv.fs_stat(candidate) then
            return candidate
          end
        end

        if dir == stop_dir then
          break
        end

        local parent = vim.fs.dirname(dir)
        if parent == dir then
          break
        end
        dir = parent
      end
    end

    --- Check if the project has a prettier config without walking above the project root.
    local function has_prettier_config(bufnr)
      local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
      return find_upward_until(prettier_configs, buf_dir, project_root(buf_dir)) ~= nil
    end

    --- Check if the project has a biome config without walking above the project root.
    local function has_biome_config(bufnr)
      local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
      return find_upward_until({ "biome.json", "biome.jsonc" }, buf_dir, project_root(buf_dir)) ~= nil
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

    -- Default formatter lists; format_on_save narrows these based on project config.
    for _, ft in ipairs(prettier_ft) do
      if biome_ft[ft] then
        formatters_by_ft[ft] = { "biome", "prettierd", "prettier", stop_after_first = true }
      else
        formatters_by_ft[ft] = { "prettierd", "prettier", stop_after_first = true }
      end
    end

    return {
      notify_on_error = true,

      format_on_save = function(bufnr)
        if vim.b[bufnr].bigfile_level == "huge" then
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
              lsp_format = "never",
              formatters = {},
            }
          end

          return {
            timeout_ms = 2000,
            lsp_format = "never",
            formatters = has_biome_config(bufnr) and { "biome", "prettierd", "prettier" } or { "prettierd", "prettier" },
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
