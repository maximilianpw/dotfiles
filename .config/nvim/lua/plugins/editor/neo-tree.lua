return {
  'nvim-neo-tree/neo-tree.nvim',
  version = 'v2.*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = { 'Neotree', 'NeoTreeReveal', 'NeoTreeToggle' },
  keys = {
    {
      '<leader>e',
      '<cmd>Neotree toggle filesystem<CR>',
      desc = 'NeoTree ▸ toggle sidebar',
      nowait = true,
    },
    {
      '<leader>r',
      '<cmd>Neotree reveal<CR>',
      desc = 'NeoTree ▸ reveal current file',
      nowait = true,
    },
  },
  opts = {
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      hijack_netrw_behavior = 'open_default',
      filtered_items = {
        visible = true,
      },
      window = {
        position = 'right',
        width = 30,
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
    buffers = {
      follow_current_file = {
        enabled = true,
      },
    },
    git_status = {
      window = {
        position = 'bottom',
      },
    },
  },
}
