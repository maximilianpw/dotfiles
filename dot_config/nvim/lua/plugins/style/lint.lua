return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        dockerfile = { 'hadolint' },
        terraform = { 'tflint' },
        text = { 'vale' },
        -- eslint_d removed - already handled by conform.nvim for formatting/fixing
        -- Diagnostics come from ESLint LSP or conform's eslint_d run
        java = { 'checkstyle' },
        nix = { 'nix' },
        go = { 'golangcilint' },
      }

      -- Debounce helper (per buffer) to avoid hammering linters while typing
      local function debounce(ms, fn)
        local timer = (vim.uv or vim.loop).new_timer()
        return function(...)
          local argv = { ... }
          timer:stop()
            timer:start(ms, 0, function()
              vim.schedule(function()
                pcall(fn, unpack(argv))
              end)
            end)
        end
      end

      -- Distinguish heavy linters (need saved state / expensive)
      local heavy = {
        golangcilint = true,
      }

      -- Run all configured linters for the buffer except heavy ones (unless forced)
      local function run_light_linters(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if not vim.bo[bufnr].modifiable then return end
        local ft = vim.bo[bufnr].filetype
        local configured = lint.linters_by_ft[ft]
        if not configured then return end
        local light_list = {}
        for _, name in ipairs(configured) do
          if not heavy[name] then table.insert(light_list, name) end
        end
        if #light_list > 0 then
          lint.try_lint(light_list)
        end
      end

      local function run_heavy_linters(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if not vim.bo[bufnr].modifiable then return end
        local ft = vim.bo[bufnr].filetype
        local configured = lint.linters_by_ft[ft]
        if not configured then return end
        local heavy_list = {}
        for _, name in ipairs(configured) do
          if heavy[name] then table.insert(heavy_list, name) end
        end
        if #heavy_list > 0 then
          lint.try_lint(heavy_list)
        end
      end

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      -- Light, responsive lint on leaving insert mode (removed TextChanged for performance)
      vim.api.nvim_create_autocmd('InsertLeave', {
        group = lint_augroup,
        callback = function(ev)
          run_light_linters(ev.buf)
        end,
      })

      -- Also lint light set when entering buffer (useful for fresh open)
      vim.api.nvim_create_autocmd('BufEnter', {
        group = lint_augroup,
        callback = function(ev)
          run_light_linters(ev.buf)
        end,
      })

      -- Heavy linters only on save to avoid constant CPU usage
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = lint_augroup,
        callback = function(ev)
          run_light_linters(ev.buf)
          run_heavy_linters(ev.buf)
        end,
      })

      -- Manual command to run everything immediately
      vim.api.nvim_create_user_command('LintNow', function(opts)
        local all = opts.args == 'all'
        if all then
          lint.try_lint()
        else
          run_light_linters()
          run_heavy_linters()
        end
      end, { desc = 'Run linters (add :LintNow all for raw try_lint)', nargs = '?' })
    end,
  },
}
