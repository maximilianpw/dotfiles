# Dotfiles guidance

## Purpose and ownership

This public repository is the chezmoi source for user-level application
configuration. Edit source names such as `dot_config/...`; do not edit rendered
files in `$HOME` and copy them back blindly. Nix/Home Manager in the separate
`nix-config` repository owns packages, executables, shells, and system settings.

- Chezmoi prefixes map source to target paths (`dot_` → `.`, `private_` changes
  target permissions). `private_` does not encrypt content.
- `.chezmoiignore` defines intentionally unmanaged targets and platform-only
  trees. Keep generated review artifacts and ignored machine state out of Git.
- `dot_config/nvim/lazy-lock.json` is the canonical plugin lock. Update it only
  as part of a deliberate plugin change; never replace it with an older target
  copy.

## Neovim boundaries

- `dot_config/nvim/lua/config/` owns startup behavior; plugin specs live under
  `lua/plugins/`; native server files live in `lsp/` and must match the enable
  list in `lua/plugins/lsp/init.lua`.
- Keep formatter ownership in `lua/plugins/style/autoformat.lua` and lint
  ownership in `lua/plugins/style/lint.lua`. External tooling is provisioned
  outside this repository; see `dot_config/nvim/NIXOS_SETUP.md`.
- Big-file behavior is a cross-cutting contract centered in
  `lua/config/bigfile.lua`; preserve its ordering and consumer guards when
  changing startup, formatting, linting, completion, or treesitter behavior.

## Local workflow and checks

Local source edits, rendering previews, formatting, and isolated tests are safe
without asking. Run the narrowest applicable check and re-run it after fixes:

- Documentation/config-only change: `git diff --check` and
  `chezmoi --source . diff`.
- Lua formatting:
  `stylua --check --config-path dot_config/nvim/.stylua.toml dot_config/nvim/lua dot_config/nvim/lsp`.
- Neovim change: `./dot_config/nvim/test.sh`; for the clean full smoke test,
  `./dot_config/nvim/test.sh --ci`.
- Broad chezmoi change: `chezmoi --source . apply --dry-run`, then inspect the
  rendered target diff. `.github/workflows/check.yml` contains the isolated-home
  render/apply verification used by CI.

Completion means the source and rendered intent agree, relevant checks pass,
and the final diff contains no target-state or secret leakage. Report checks
that could not run.

## Safety boundaries

- Never add credentials, tokens, private keys, employer data, or machine-local
  account details. Use an encrypted secret store; this repository is public.
- Do not run `chezmoi apply`, `test.sh --apply`, plugin-update commands, or other
  writes to a real home directory unless explicitly requested. A dry run is not
  permission to apply.
