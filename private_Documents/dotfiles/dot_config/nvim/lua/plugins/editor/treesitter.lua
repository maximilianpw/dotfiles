-- Treesitter configuration for syntax highlighting
local function should_disable(lang, buf)
  local name = vim.api.nvim_buf_get_name(buf)
  -- 1) Skip any buffer in node_modules or vendor
  if name:match '/node_modules/' or name:match '/vendor/' then
    return true
  end
  -- 2) Skip files over 200 KB
  local ok, stat = pcall(vim.loop.fs_stat, name)
  if ok and stat and stat.size > 200 * 1024 then
    return true
  end
  -- 3) Skip Ruby indent highlighting if you still want regex indent
  if lang == 'ruby' then
    return true
  end
  return false
end

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs',
  opts = {
    ensure_installed = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim' },
    auto_install = false,
    sync_install = false,
    ignore_install = { 'php' },

    highlight = {
      enable = true,
      disable = should_disable,
      additional_vim_regex_highlighting = { 'ruby' },
    },

    indent = {
      enable = true,
      disable = should_disable,
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },

    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
    },

    playground = { enable = true },
    context_playground = { enable = true },
  },
}
