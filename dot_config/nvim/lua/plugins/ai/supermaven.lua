return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  opts = {
    disable_inline_completion = false,
    disable_keymaps = false,
    -- <Tab> accepts suggestions contextually through Blink; keep <C-l> as a direct AI fallback.
    keymaps = { accept_suggestion = "<C-l>" },
  },
}
