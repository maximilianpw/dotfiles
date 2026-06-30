# Neovim Tooling Setup

This config manages Neovim plugins with lazy.nvim, but it does not provision external language tools. LSP servers, formatters, linters, and debug adapters should be installed through the host system: Nix, Homebrew, npm, Go, Rustup, or project-local tooling.

## NixOS

Install the tools you use in your NixOS or home-manager configuration. Example package set:

```nix
home.packages = with pkgs; [
  alejandra
  bash-language-server
  biome
  black
  checkstyle
  clang-tools
  delve
  dockerfile-language-server
  gopls
  golangci-lint
  hadolint
  lua-language-server
  nil
  nodejs
  nodePackages.typescript
  oxlint
  prettierd
  ruff
  shfmt
  stylua
  tailwindcss-language-server
  taplo
  tflint
  vscode-langservers-extracted
  yaml-language-server
  zls
];
```

Add optional tools only when needed: `lldb`/`lldb-dap` for Rust debugging, `vale` for prose, and JavaScript debug adapters if they are not available through Mason or PATH.

## Enabled LSP Servers

`lua/plugins/lsp/init.lua` enables these native Neovim LSP configs:

- `bashls`
- `biome`
- `cssls`
- `dockerls`
- `eslint`
- `gopls`
- `html`
- `jsonls`
- `lua_ls`
- `nil_ls`
- `nushell`
- `tailwindcss`
- `taplo`
- `yamlls`
- `zls`

Rust is handled by `rustaceanvim`, not the shared LSP server list. TypeScript is handled by `typescript-tools`, which needs the `typescript` package's `tsserver`. The `nushell` server is `nu --lsp`, provided by the nushell package itself.

Server-specific settings live in `lsp/*.lua`.

## Formatters And Linters

Formatting is configured in `lua/plugins/style/autoformat.lua` through conform.nvim. Go formatting is owned by conform.nvim with `goimports` and `gofmt`.

Linting is configured in `lua/plugins/style/lint.lua` through nvim-lint. ESLint diagnostics come from the ESLint LSP, not nvim-lint:

- `oxlint` runs when `oxlintrc.json` or `.oxlintrc.json` exists.
- Heavy linters run on save only.

## Debugging

DAP setup is split under `lua/config/dap/`:

- `ui.lua` configures dap-ui, signs, listeners, and virtual text.
- `js.lua` configures JavaScript and TypeScript debug adapters.
- `languages.lua` configures Go and Rust adapters.
- `breakpoints.lua` configures persistent breakpoints.

JavaScript debugging looks for `js-debug`, `js-debug-adapter`, or Mason's `js-debug-adapter` package. If none are available, Neovim shows a warning when DAP loads.

## Troubleshooting

Use these commands inside Neovim:

```vim
:checkhealth
:LspInfo
:ConformInfo
:LintNow
:Lazy
```

Use shell checks to verify tools are on PATH:

```bash
which gopls
which lua-language-server
which prettierd
which stylua
which vscode-eslint-language-server
```
