return {
  "dmtrKovalenko/fff.nvim",
  build = "cargo build --release",
  keys = {
    {
      "<leader>ff",
      function()
        require("fff").find()
      end,
      desc = "Find Files (fff)",
    },
    {
      "<leader>fc",
      function()
        require("fff").find({ base_path = "~/.local/share/chezmoi/dot_config/nvim" })
      end,
      desc = "Find Config Files",
    },
  },
  opts = {},
}
