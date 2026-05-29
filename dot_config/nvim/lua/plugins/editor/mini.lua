-- mini.nvim: a collection of small, focused editing modules.
return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    require("mini.ai").setup({ n_lines = 250 })
    require("mini.move").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.splitjoin").setup()
    require("mini.align").setup()
    require("mini.trailspace").setup()
    require("mini.sessions").setup()

    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      },
    })
  end,
  keys = {
    {
      "<leader>qs",
      function()
        require("mini.sessions").select("read")
      end,
      desc = "Select Session",
    },
    {
      "<leader>ql",
      function()
        require("mini.sessions").read()
      end,
      desc = "Restore Latest Session",
    },
    {
      "<leader>qw",
      function()
        require("mini.sessions").write()
      end,
      desc = "Write Session",
    },
    {
      "<leader>qd",
      function()
        require("mini.sessions").select("delete")
      end,
      desc = "Delete Session",
    },
    {
      "<leader>cw",
      function()
        require("mini.trailspace").trim()
        require("mini.trailspace").trim_last_lines()
      end,
      desc = "Trim Whitespace",
    },
  },
}
