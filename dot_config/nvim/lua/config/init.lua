-- Config module index
-- Load all configuration in the correct order
require("config.options")
require("config.bigfile")
require("config.keymaps")
require("config.autocmds")

-- vscode-neovim keymap bridge (no-op outside VS Code/Cursor)
require("config.vscode")
