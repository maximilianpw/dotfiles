-- Load core configuration
require("config")

-- Install lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Configure and install plugins
require("lazy").setup({
  {
    "sainnhe/everforest",
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_better_performance = 1
      vim.cmd.colorscheme("everforest")
    end,
  },
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
  {
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
  },
  { import = "plugins.editor" },
  { import = "plugins.git" },
  { import = "plugins.lsp" },
  { import = "plugins.style" },
  { import = "plugins.testing" },
  { import = "plugins.ui" },
  { import = "plugins.ai" },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
