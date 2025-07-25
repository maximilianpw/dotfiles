return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
    {
      'folke/ts-comments.nvim',
      event = 'VeryLazy',
      opts = {},
    },
  },
}
