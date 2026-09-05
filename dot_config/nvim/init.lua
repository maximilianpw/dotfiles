-- Resolve source-relative modules even when this file is passed with -u.
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.rtp:prepend(config_dir)
require("config")

-- Install lazy.nvim plugin manager
local lockfile = config_dir .. "/lazy-lock.json"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
  -- Pin the manager too: its first install otherwise rewrites its own lock entry.
  local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  out = vim.fn.system({ "git", "-C", lazypath, "checkout", "--detach", lock["lazy.nvim"].commit })
  if vim.v.shell_error ~= 0 then
    error("Error restoring lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Keep the full graph with conditional loading: omitted imports would let a
-- VS Code Lazy update/clean discard terminal plugins and their lock entries.
local vscode_plugins = {
  ["lazy.nvim"] = true,
  ["mini.nvim"] = true,
  ["flash.nvim"] = true,
  ["nvim-treesitter"] = true,
  ["nvim-treesitter-textobjects"] = true,
  ["ts-comments.nvim"] = true,
}
require("lazy").setup({
  { import = "plugins.editor" },
  { import = "plugins.git" },
  { import = "plugins.lsp" },
  { import = "plugins.style" },
  { import = "plugins.testing" },
  { import = "plugins.ui" },
  { import = "plugins.ai" },
}, {
  defaults = {
    cond = function(plugin)
      return not vim.g.vscode or vscode_plugins[plugin.name] == true
    end,
  },
  lockfile = lockfile,
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      -- Keep netrw: neo-tree is lazy-loaded, so `nvim <dir>` still needs it.
      disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor" },
    },
  },
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
