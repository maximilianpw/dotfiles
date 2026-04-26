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
      },
    })

    -- Unified <leader>t* test keymaps
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc })
    end
    map("<leader>tn", function()
      require("neotest").run.run()
    end, "Test: Run nearest")
    map("<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, "Test: Run file")
    map("<leader>tF", function()
      require("neotest").run.run(vim.fn.getcwd())
    end, "Test: Run project")
    map("<leader>ts", function()
      require("neotest").summary.toggle()
    end, "Test: Toggle summary")
    map("<leader>to", function()
      require("neotest").output.open({ enter = true })
    end, "Test: Open output")
    map("<leader>tO", function()
      require("neotest").output_panel.toggle()
    end, "Test: Toggle output panel")
    map("<leader>td", function()
      require("neotest").run.run({ strategy = "dap" })
    end, "Test: Debug nearest (DAP)")
    map("<leader>tS", function()
      require("neotest").run.run({ suite = true })
    end, "Test: Run suite (nearest root)")
  end,
}
