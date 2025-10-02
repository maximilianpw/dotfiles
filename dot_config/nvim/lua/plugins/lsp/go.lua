return {
  "ray-x/go.nvim",
  ft = { "go", "gomod", "gosum", "gotmpl" },
  event = "CmdlineEnter",
  build = ':lua require("go.install").update_all_sync()',
  dependencies = {
    "mfussenegger/nvim-dap",
    "leoluz/nvim-dap-go",
    "nvim-neotest/neotest",
    "nvim-neotest/neotest-go",
  },
  opts = {
    lsp_cfg = {
      settings = {
        gopls = {
          staticcheck = true,
          analyses = {
            unusedparams = true,
            nilness = true,
            shadow = true,
            unusedwrite = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    },
    lsp_inlay_hints = { enable = true },
    trouble = false,
    luasnip = true,
    dap_debug = true,
  },
  config = function(_, opts)
    require("go").setup(opts)

    -- Format & organize imports on save (avoid double-formatting if conform.nvim also formats Go)
    local format_group = vim.api.nvim_create_augroup("GoFormat", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      group = format_group,
      callback = function()
        local ok_fmt, gofmt = pcall(require, "go.format")
        if ok_fmt then
          gofmt.goimports()
        end
      end,
    })

    -- DAP integration (delve) if available
    local ok_dapgo, dap_go = pcall(require, "dap-go")
    if ok_dapgo then
      dap_go.setup()
    end

    -- Register neotest-go adapter without clobbering existing adapters
    local ok_neotest, neotest = pcall(require, "neotest")
    if ok_neotest then
      local ok_neotest_go, neotest_go = pcall(require, "neotest-go")
      if ok_neotest_go then
        local cfg = require("neotest.config")
        local adapters = cfg.adapters or {}
        local already_added = false
        for _, adapter in ipairs(adapters) do
          if adapter.name == "neotest-go" then
            already_added = true
            break
          end
        end
        if not already_added then
          local adapter = neotest_go({
            experimental = { test_table = true },
            args = { "-count=1" },
          })
          if neotest.register_adapter then
            neotest.register_adapter(adapter)
          else
            adapters[#adapters + 1] = adapter
            cfg.adapters = adapters
          end
        end
      end
    end
  end,
}
