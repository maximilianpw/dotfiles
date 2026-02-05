# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Chezmoi-managed dotfiles. All target files use chezmoi's `dot_` prefix convention (e.g. `dot_config/nvim/` → `~/.config/nvim/`). Directories prefixed `private_` contain sensitive configs. A `.chezmoiignore` excludes `.claude/` from deployment. No templates or external sources are used.

To preview changes: `chezmoi diff`
To dry-run apply: `chezmoi apply --dry-run`
To apply: `chezmoi apply`

## Neovim Config Architecture

The neovim config (`dot_config/nvim/`) is the bulk of this repo (~50 Lua files).

**Bootstrap order** (in `lua/config/init.lua`): options → bigfile → keymaps → autocmds. Then `init.lua` loads lazy.nvim and imports plugin categories.

**Plugin categories** (`lua/plugins/`):
- `ai/` - AI assistants
- `editor/` - Completion (blink.cmp), treesitter, flash navigation, file finder, which-key
- `git/` - gitsigns
- `lsp/` - Language-specific plugin configs (typescript-tools, go.nvim, rustaceanvim, omnisharp)
- `style/` - conform.nvim (formatting), nvim-lint (linting)
- `testing/` - neotest, DAP debugging (Go/C#/JS/Rust)
- `ui/` - snacks.nvim (picker, git, notifications, dashboard), neo-tree, lualine, bufferline, noice

**LSP servers** are configured as individual files in `lsp/` (e.g. `lsp/gopls.lua`, `lsp/pyright.lua`). There are 14+ servers. The main LSP setup (`lua/plugins/lsp/init.lua`) defines shared keymaps and diagnostics via `LspAttach` autocmd.

### Bigfile System

Central performance optimization in `lua/config/bigfile.lua`. Three tiers stored in `vim.g.bigfile`:
- **large** (100KB): disables cursorline, relativenumber
- **max_ts** (150KB): disables syntax, treesitter
- **huge** (200KB): disables formatting

Sets `vim.b.bigfile` (boolean) and `vim.b.bigfile_level` (string) per buffer. Global helper `_G.is_bigfile(bufnr, level)` available. Multiple modules check these: LSP init (document highlighting), typescript (semantic tokens), autoformat (format-on-save), gitsigns.

### Formatter/Linter Pattern

Formatters (conform.nvim) use `stop_after_first = true` for prettier-based entries. LSP fallback for languages without dedicated formatters. Linters (nvim-lint) split into "light" (InsertLeave/BufEnter) and "heavy" (BufWritePost only) categories with per-buffer debounce timers.

### Cross-platform

NixOS vs macOS detection via `/etc/NIXOS`. Node path auto-detected in `lua/config/options.lua` and stored in `vim.g.node_host_prog`. See `dot_config/nvim/NIXOS_SETUP.md` for LSP/formatter package details.

## Code Patterns

**Error handling**: `local ok, mod = pcall(require, "name")` with `vim.notify` on failure — used throughout for optional plugin features.

**Plugin specs**: lazy.nvim format. Use `ft` for language-specific, `event` for deferred, `cmd` for on-demand loading.

**Indentation**: Lua files use tabs. JSON files use 2-space indent.

**Keybind groups** (defined in which-key): `<leader>c` code, `<leader>f` find, `<leader>g` git, `<leader>d` debug, `<leader>t` test, `<leader>x` trouble, `<leader>e` explorer, `<leader>s` search/replace.
