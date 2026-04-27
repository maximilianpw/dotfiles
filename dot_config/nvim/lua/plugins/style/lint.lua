return {

  { -- Linting
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Override oxlint args to pass the config file it finds
      local oxlint = lint.linters.oxlint
      oxlint.args = function()
        local cfg = vim.fs.find({ "oxlintrc.json", ".oxlintrc.json" }, {
          upward = true,
          path = vim.fn.expand("%:p:h"),
        })
        if cfg[1] then
          return { "--format", "github", "-c", cfg[1] }
        end
        return { "--format", "github" }
      end

      -- JS/TS lint ownership: ESLint diagnostics/code actions come from the ESLint LSP;
      -- nvim-lint only adds non-LSP tools such as oxlint.
      local js_ts_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        text = { "vale" },
        java = { "checkstyle" },
        nix = { "nix" },
        go = { "golangcilint" },
      }

      --- Check if a project has an oxlint config anywhere above the buffer
      local function has_oxlint_config(bufnr)
        local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
        return #vim.fs.find({ "oxlintrc.json", ".oxlintrc.json" }, { upward = true, path = buf_dir }) > 0
      end

      -- Distinguish heavy linters (need saved state / expensive)
      local heavy = {
        golangcilint = true,
      }

      --- Get the effective linter list for a buffer, including dynamic JS/TS linters
      local function get_linters(bufnr)
        local ft = vim.bo[bufnr].filetype
        local configured = lint.linters_by_ft[ft]
        local linters = configured and vim.list_slice(configured) or {}
        if vim.tbl_contains(js_ts_fts, ft) then
          if has_oxlint_config(bufnr) then
            table.insert(linters, "oxlint")
          end
        end
        return linters
      end

      -- Run all configured linters for the buffer except heavy ones (unless forced)
      local function run_light_linters(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if not vim.bo[bufnr].modifiable then
          return
        end
        local light_list = {}
        for _, name in ipairs(get_linters(bufnr)) do
          if not heavy[name] then
            table.insert(light_list, name)
          end
        end
        if #light_list > 0 then
          lint.try_lint(light_list)
        end
      end

      local function run_heavy_linters(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if not vim.bo[bufnr].modifiable then
          return
        end
        local heavy_list = {}
        for _, name in ipairs(get_linters(bufnr)) do
          if heavy[name] then
            table.insert(heavy_list, name)
          end
        end
        if #heavy_list > 0 then
          lint.try_lint(heavy_list)
        end
      end

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      -- Light, responsive lint on leaving insert mode (removed TextChanged for performance)
      vim.api.nvim_create_autocmd("InsertLeave", {
        group = lint_augroup,
        callback = function(ev)
          run_light_linters(ev.buf)
        end,
      })

      -- Also lint light set when entering buffer (useful for fresh open)
      vim.api.nvim_create_autocmd("BufEnter", {
        group = lint_augroup,
        callback = function(ev)
          run_light_linters(ev.buf)
        end,
      })

      -- Heavy linters only on save to avoid constant CPU usage
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = lint_augroup,
        callback = function(ev)
          run_light_linters(ev.buf)
          run_heavy_linters(ev.buf)
        end,
      })

      -- Manual command to run everything immediately
      vim.api.nvim_create_user_command("LintNow", function(opts)
        local all = opts.args == "all"
        if all then
          lint.try_lint()
        else
          run_light_linters()
          run_heavy_linters()
        end
      end, { desc = "Run linters (add :LintNow all for raw try_lint)", nargs = "?" })
    end,
  },
}
