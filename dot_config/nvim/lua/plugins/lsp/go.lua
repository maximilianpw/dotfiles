return {
  "ray-x/go.nvim",
  ft = { "go", "gomod", "gosum", "gotmpl" },
  -- Tools are supplied by Nix or the project, not installed during plugin builds.
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
