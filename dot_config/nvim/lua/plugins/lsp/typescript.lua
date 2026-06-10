return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      local ok_ts, typescript_tools = pcall(require, "typescript-tools")
      if not ok_ts then
        vim.notify("typescript-tools.nvim not found: " .. tostring(typescript_tools), vim.log.levels.ERROR)
        return
      end

      local setup_opts = {
        -- typescript-tools handles root_dir automatically
        -- It looks for: tsconfig.json, jsconfig.json, package.json, .git
        single_file_support = true,
        handlers = {
          ["textDocument/semanticTokens/full"] = function(err, result, ctx, config)
            -- Skip semantic tokens for large files (performance optimization)
            if ctx and ctx.bufnr and _G.is_bigfile and _G.is_bigfile(ctx.bufnr) then
              return nil
            end
            return vim.lsp.handlers["textDocument/semanticTokens/full"](err, result, ctx, config)
          end,
        },
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = "all",
          debounce_text_changes = 300, -- Debounce to reduce server load
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "literals",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayEnumMemberValueHints = false,
          },
        },
      }

      typescript_tools.setup(setup_opts)
    end,
  },
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "typescriptreact" },
    opts = {},
  },
  {
    "vuki656/package-info.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    -- Only relevant for package.json, not every JSON file
    event = "BufRead package.json",
    opts = {
      highlights = {
        up_to_date = {
          fg = "#3C4048",
        },
        outdated = {
          fg = "#fc514e",
        },
      },
    },
  },
}
