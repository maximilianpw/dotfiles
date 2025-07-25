return {
  'nvim-neo-tree/neo-tree.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  cmd = { 'Neotree', 'NeoTreeToggle' },
  keys = {
    {
      '<leader>e',
      '<cmd>Neotree toggle filesystem<CR>',
      desc = 'NeoTree ▸ toggle sidebar',
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
