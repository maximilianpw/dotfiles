-- Basic autocommands (non-plugin)

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Close certain windows with 'q'
vim.api.nvim_create_autocmd("FileType", {
  desc = "Close certain filetypes with 'q'",
  group = vim.api.nvim_create_augroup("close-with-q", { clear = true }),
  pattern = { "help", "qf", "checkhealth", "man", "lspinfo", "startuptime" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create directories when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Auto-create directories when saving",
  group = vim.api.nvim_create_augroup("auto-create-dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Check if file changed outside vim
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Check if files changed outside vim",
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
