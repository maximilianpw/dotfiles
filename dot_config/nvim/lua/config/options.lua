-- Basic Neovim options
-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Auto-detect node path
local node = vim.fn.exepath("node")
if node ~= "" then
  vim.g.node_host_prog = node
end

-- Speed up Lua module loading
if vim.loader then
  vim.loader.enable()
end

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse and mode
vim.opt.mouse = "a"
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Indentation and editing
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true

-- Tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Buffer setup
vim.opt.termguicolors = true

-- Completion settings (for blink.cmp)
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 15 -- Limit completion menu height

-- Additional UI improvements
vim.opt.virtualedit = "block" -- Allow cursor beyond end of line in visual block mode
vim.opt.fillchars = { -- Better window separators
  fold = "⸱",
  foldopen = "▾",
  foldclose = "▸",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.opt.smoothscroll = true -- Smooth scrolling for long lines (nvim 0.10+)
vim.opt.foldlevel = 99 -- Start with folds open
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "" -- Use treesitter for fold text

-- Search improvements
vim.opt.hlsearch = true -- Explicitly enable search highlighting
vim.opt.incsearch = true -- Show matches as you type

-- Wildmenu improvements
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", ".git", "node_modules", "*.pyc" })
