return {
  "MeanderingProgrammer/render-markdown.nvim",
  cond = not vim.g.vscode,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "markdown", "norg", "rmd", "org" },
  opts = {
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    heading = {
      sign = false,
      icons = {},
    },
  },
}
