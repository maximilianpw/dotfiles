# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Chezmoi-managed dotfiles. All target files use chezmoi's `dot_` prefix convention (e.g. `dot_config/nvim/` → `~/.config/nvim/`). A `private_` prefix changes target permissions only; it does **not** encrypt file contents or make them safe to commit. This repository is public, so never add credentials, tokens, private keys, employer material, or other secrets. Secret values belong in a password manager or another encrypted secret store. `.chezmoiignore` excludes `.claude/` from deployment and keeps `~/.aws` and `~/.config/btop` unmanaged. `lazy-lock.json` is tracked and the source copy is canonical; apply chezmoi after a deliberate plugin update rather than copying an older target lockfile back over it. The Glow config is templated for a portable home path; no external sources are used.

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
- `lsp/` - Language-specific plugin configs (typescript-tools, go.nvim, rustaceanvim)
- `style/` - conform.nvim (formatting), nvim-lint (linting)
- `testing/` - neotest, DAP debugging (Go/JS/Rust)
- `ui/` - snacks.nvim (picker, git, notifications, dashboard), neo-tree, lualine, bufferline, noice

**LSP servers** are configured as individual files in `lsp/` (e.g. `lsp/gopls.lua`, `lsp/lua_ls.lua`). Each enabled server has a file there. The main LSP setup (`lua/plugins/lsp/init.lua`) defines shared keymaps and diagnostics via `LspAttach` autocmd.

### Bigfile System

Central performance optimization in `lua/config/bigfile.lua`. Three tiers stored in `vim.g.bigfile`:
- **large** (100KB): disables cursorline, relativenumber
- **max_ts** (150KB): disables syntax, treesitter
- **huge** (200KB): disables formatting

Sets `vim.b.bigfile` (boolean) and `vim.b.bigfile_level` (string) per buffer. Global helper `_G.is_bigfile(bufnr, level)` available. Multiple modules check these: treesitter setup, nvim-lint, blink buffer sources, typescript semantic-token handling, and autoformat-on-save. Gitsigns uses its own line-count limit instead.

### Formatter/Linter Pattern

Formatters (conform.nvim) use `stop_after_first = true` for prettier-based entries. LSP fallback for languages without dedicated formatters. Linters (nvim-lint) split into "light" (FileType/InsertLeave) and "heavy" (BufWritePost only) categories.

### Cross-platform

Node is discovered from `PATH` in `lua/config/options.lua` and stored in `vim.g.node_host_prog`. See `dot_config/nvim/NIXOS_SETUP.md` for NixOS LSP/formatter package details.

## Code Patterns

**Error handling**: `local ok, mod = pcall(require, "name")` with `vim.notify` on failure — used throughout for optional plugin features.

**Plugin specs**: lazy.nvim format. Use `ft` for language-specific, `event` for deferred, `cmd` for on-demand loading.

**Indentation**: Lua files use 2-space indent (enforced by `.stylua.toml`). JSON files use 2-space indent.

**Keybind groups** (defined in which-key): `<leader>c` code, `<leader>f` find, `<leader>g` git, `<leader>d` debug, `<leader>t` test, `<leader>e` explorer, `<leader>s` search/replace, `<leader>O` obsidian, `<leader>q` session.
