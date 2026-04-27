return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
    "adrigzr/neotest-mocha",
    "nvim-neotest/neotest-go",
  },
  keys = {
    {
      "<leader>tn",
      function()
        require("neotest").run.run()
      end,
      desc = "Test: Run nearest",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Test: Run file",
    },
    {
      "<leader>tF",
      function()
        require("neotest").run.run(vim.fn.getcwd())
      end,
      desc = "Test: Run project",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Test: Toggle summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open({ enter = true })
      end,
      desc = "Test: Open output",
    },
    {
      "<leader>tO",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Test: Toggle output panel",
    },
    {
      "<leader>td",
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Test: Debug nearest (DAP)",
    },
    {
      "<leader>tS",
      function()
        require("neotest").run.run({ suite = true })
      end,
      desc = "Test: Run suite (nearest root)",
    },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-jest")({
          jestCommand = "npm test --",
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-vitest")({
          filter_dir = function(name, rel_path, root)
            return name ~= "node_modules" and name ~= "dist"
          end,
        }),
        require("neotest-mocha")({
          command = "npm test --",
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-go")({
          experimental = { test_table = true },
          args = { "-count=1" },
        }),
      },
    })
  end,
}
