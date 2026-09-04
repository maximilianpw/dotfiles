-- Consolidated big-file handling
-- Single source of truth for all file size thresholds

vim.g.bigfile = {
  large = 100 * 1024, -- 100KB: Disable expensive UI features
  max_ts = 150 * 1024, -- 150KB: Disable treesitter, completion buffer sources
  huge = 200 * 1024, -- 200KB: Disable formatting
}

local function classify(bufnr)
  vim.b[bufnr].bigfile = false
  vim.b[bufnr].bigfile_level = nil

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or vim.bo[bufnr].buftype ~= "" then
    return
  end

  local ok, stat = pcall((vim.uv or vim.loop).fs_stat, name)
  if not ok or not stat then
    return
  end

  if stat.size > vim.g.bigfile.huge then
    vim.b[bufnr].bigfile = true
    vim.b[bufnr].bigfile_level = "huge"
  elseif stat.size > vim.g.bigfile.max_ts then
    vim.b[bufnr].bigfile = true
    vim.b[bufnr].bigfile_level = "max_ts"
  elseif stat.size > vim.g.bigfile.large then
    vim.b[bufnr].bigfile = true
    vim.b[bufnr].bigfile_level = "large"
  end
end

local group = vim.api.nvim_create_augroup("bigfile-optimizations", { clear = true })

-- Classify before lazy-loaded FileType consumers can start expensive work.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  desc = "Classify large files before plugin setup",
  group = group,
  callback = function(args)
    classify(args.buf)
  end,
})

-- Reclassify after the read in case the file changed, then enforce UI/parser policy.
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Disable expensive features for large files",
  group = group,
  callback = function(args)
    local bufnr = args.buf
    classify(bufnr)

    -- Large file: disable expensive UI features
    if vim.b[bufnr].bigfile then
      vim.opt_local.cursorline = false
      vim.opt_local.relativenumber = false
      vim.opt_local.scrolloff = 3
    end

    -- Max treesitter: disable syntax features
    if _G.is_bigfile and _G.is_bigfile(bufnr, "max_ts") then
      vim.treesitter.stop(bufnr)
      vim.opt_local.syntax = "off"
      vim.opt_local.foldmethod = "manual"
    end
  end,
})

-- Helper function for other modules to check file size
_G.is_bigfile = function(bufnr, level)
  bufnr = bufnr or 0
  level = level or "large"

  if vim.b[bufnr].bigfile then
    if level == "large" then
      return true
    end
    local buf_level = vim.b[bufnr].bigfile_level
    if level == "max_ts" and (buf_level == "max_ts" or buf_level == "huge") then
      return true
    end
    if level == "huge" and buf_level == "huge" then
      return true
    end
  end
  return false
end
