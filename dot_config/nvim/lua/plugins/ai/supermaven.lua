return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  opts = {
    disable_inline_completion = false,
    disable_keymaps = false,
    -- Leave <Tab> to Blink's snippet navigation.
    keymaps = { accept_suggestion = "<C-l>" },
  },
}
