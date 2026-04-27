return {
  "ray-x/go.nvim",
  ft = { "go", "gomod", "gosum", "gotmpl" },
  event = "CmdlineEnter",
  build = ':lua require("go.install").update_all_sync()',
  opts = {
    -- Disable go.nvim's LSP handling (use native lspconfig instead)
    lsp_cfg = false,
    lsp_gofumpt = false,
    lsp_inlay_hints = { enable = false },
    trouble = false,
    luasnip = false,
    dap_debug = false,
  },
  config = function(_, opts)
    require("go").setup(opts)
  end,
}
