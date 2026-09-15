# mise-en-place as config/dotfile management for this chezmoi repo

**Date:** 2026-09-14
**Question:** Can current mise `bootstrap` / `[dotfiles]` replace, complement, or only bootstrap this public chezmoi source repository (`/Users/max-vev/.local/share/chezmoi`)?

## Version and source scope

Claims below are scoped to these primary sources, retrieved 2026-09-14 unless noted:

| Artifact | Version / date | Source |
| --- | --- | --- |
| mise docs site | current published site | [https://mise.jdx.dev](https://mise.jdx.dev) |
| mise latest GitHub release | **v2026.9.7** (2026-09-13) | [https://github.com/jdx/mise/releases/tag/v2026.9.7](https://github.com/jdx/mise/releases/tag/v2026.9.7) |
| First `mise bootstrap` + `[dotfiles]` GA | **v2026.6.6** | [https://github.com/jdx/mise/releases/tag/v2026.6.6](https://github.com/jdx/mise/releases/tag/v2026.6.6) |
| Tracked/history/sync model | **v2026.9.2** (2026-09-07) | [https://github.com/jdx/mise/releases/tag/v2026.9.2](https://github.com/jdx/mise/releases/tag/v2026.9.2), [jdx.dev post](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/) |
| Destination variants | **v2026.9.5** (2026-09-10) | [CHANGELOG](https://github.com/jdx/mise/blob/main/CHANGELOG.md) |
| Secrets in dotfile templates | **v2026.9.7** (2026-09-13) | [v2026.9.7 notes](https://github.com/jdx/mise/releases/tag/v2026.9.7) |
| Local `mise` on this machine | **2026.5.12** | `mise --version` (predates the entire current bootstrap/dotfiles surface) |
| chezmoi docs | latest site says **2.72.2** | [https://www.chezmoi.io](https://www.chezmoi.io) |
| This repo’s CI pin | **2.70.4** | `.github/workflows/check.yml` |
| Local chezmoi | **2.70.3** (nixpkgs) | `chezmoi --version` |

mise releases on a calendar version (`YYYY.M.PATCH`) and has shipped bootstrap/dotfiles changes in nearly every 2026.6–2026.9 patch. Treat any workflow copied from this note as **version-sensitive** and re-read [https://mise.jdx.dev/dotfiles.html](https://mise.jdx.dev/dotfiles.html) and [https://mise.jdx.dev/bootstrap.html](https://mise.jdx.dev/bootstrap.html) before acting.

This repository is a public chezmoi source: `dot_` / `private_` / `executable_` prefixes, a templated `.chezmoiignore`, one content template (`dot_config/glow/glow.yml.tmpl`), no encrypted files, no `run_` scripts, no externals. Nix/Home Manager in a separate repo owns packages, shells, and system settings ([`AGENTS.md`](../../AGENTS.md)).

---

## Recommendation (short)

**Do not replace chezmoi with mise for this repository.** Use mise, if at all, as a **complement**: tool/runtime management and optional machine bootstrap *around* chezmoi, not as the public source-of-truth for these files.

Reasons, in order:

1. This repo is already a mature, public, prefix-mapped chezmoi source with isolated-home CI (`chezmoi --destination "$HOME" apply` + `verify`). mise’s documented apply path writes live home paths and has no documented chezmoi-style `--destination` isolation ([`mise dotfiles apply`](https://mise.jdx.dev/cli/dotfiles/apply.html), [bootstrap](https://mise.jdx.dev/bootstrap.html)).
2. The workflow that mise now *promotes* for “dotfiles that save themselves” is **in-place tracking + a private Git origin**, not a public source tree with encoded filenames. Official docs tell you to use a **private** repository because checkpoints include earlier contents ([dotfiles](https://mise.jdx.dev/dotfiles.html), [history](https://mise.jdx.dev/history.html), [2026-09-07 post](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/)).
3. Package/shell ownership is already assigned to Nix/Home Manager. mise bootstrap packages would compete with that contract ([Nix packages](https://mise.jdx.dev/bootstrap/packages/nix.html), [`AGENTS.md`](../../AGENTS.md)).
4. The feature is young and still moving: `[dotfiles]` arrived in **2026.6.6**; tracking/history in **2026.9.2**; destination variants in **2026.9.5**; template secrets in **2026.9.7**. This machine’s mise (**2026.5.12**) cannot even run it.

A small proof-of-concept is at the end. It is **not implemented**.

---

## 1. What this repository actually manages

Observed from the source tree (not from `$HOME`):

| Trait | This repo |
| --- | --- |
| File count (excluding `.git`) | ~111 files; bulk is `dot_config/nvim/` |
| Prefixes in use | `dot_`, `private_`, `executable_`; one `.tmpl` |
| Unused chezmoi features | `encrypted_`, `exact_`, `run_` / `once_` / `before_` / `after_`, `modify_`, `create_`, `symlink_`, `empty_`, externals |
| Platform split | `.chezmoiignore` is itself a template: ignore `Library/` unless `.chezmoi.os == "darwin"` |
| Permissions intent | `private_*` directories/files (chezmoi maps this to `0600`/`0700`; it does **not** encrypt) ([source-state attributes](https://www.chezmoi.io/reference/source-state-attributes/)) |
| Executables | `private_dot_local/bin/executable_herdr-shell`, `executable_lazygit-nvim-edit` |
| Content template | `dot_config/glow/glow.yml.tmpl` uses `joinPath .chezmoi.homeDir ...` |
| Intentionally unmanaged | `.aws`, `.config/btop`, Amp settings, Zed conversations/themes, employer data |
| Empty placeholder | `dot_config/mise/` exists and is empty |
| CI | gitleaks, stylua, isolated chezmoi render/apply/`verify`, nvim smoke tests |

chezmoi’s model here matches its documented design: a **single source of truth** that *generates* regular files in `$HOME`, with metadata in filenames, so the repo can stay public and ignore VCS control files that start with `.` ([design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/), [source-state attributes](https://www.chezmoi.io/reference/source-state-attributes/)).

Daily loop documented by chezmoi and used by this repo’s `AGENTS.md`:

```
edit source → chezmoi --source . diff → chezmoi apply --dry-run → chezmoi apply
```

([daily operations](https://www.chezmoi.io/user-guide/daily-operations/), [`apply`](https://www.chezmoi.io/reference/commands/apply/), [`diff`](https://www.chezmoi.io/reference/commands/diff/), [`verify`](https://www.chezmoi.io/reference/commands/verify/)).

---

## 2. What mise currently is

mise is a single CLI for **tools, env, tasks, and (since 2026.6) machine bootstrap**. The homepage states it can “Add machine setup with `mise bootstrap` when you need system packages, dotfiles, or services” ([https://mise.jdx.dev](https://mise.jdx.dev)).

That is a different product shape from chezmoi:

- chezmoi: home-directory **state manager** (templates, encryption, password managers, scripts).
- mise: **dev-tool + project environment + task runner**, with an expanding **workstation provisioner** bolted on.

The author now describes three dotfile models inside mise ([2026-09-07 post](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/)):

1. Stow-like: keep files in a repo and **symlink** them into place.
2. chezmoi-like: **generate** live files from stored sources/templates.
3. **New (2026.9.2):** edit live files in place; a watcher checkpoints them to a separate Git store and optionally syncs a **private** origin.

This repo is model (2) today. mise can do (1) and (2) via `[dotfiles]`, and now prefers (3) in its “set up a machine” guide ([setup](https://mise.jdx.dev/bootstrap/setup.html)).

---

## 3. `mise bootstrap` and `[dotfiles]`: capabilities

### 3.1 Bootstrap is a sequenced provisioner, not a transaction

`mise bootstrap` applies declared machine setup in a fixed order ([bootstrap](https://mise.jdx.dev/bootstrap.html), [CLI](https://mise.jdx.dev/cli/bootstrap.html)):

1. `[bootstrap.secrets]` preflight for file/dotfile templates
2. Linux accounts/groups
3. package-manager plugins; `phase = "pre-packages"` files
4. `[bootstrap.packages]`
5. remaining `[bootstrap.files]` / `[bootstrap.directories]`
6. services, firewall, Compose
7. `[bootstrap.repos]`
8. **`mise dot apply` for `[dotfiles]`**
9. shell activation, macOS defaults/LaunchAgents, systemd user units, login shell
10. `mise install` for `[tools]`
11. plugin packages and services that `requires_tools`
12. task named `bootstrap`, then `[bootstrap.hooks.final]`

Documented properties:

- Unchanged resource state is skipped; **hooks and the `bootstrap` task re-run every selected apply** and must be made idempotent ([bootstrap](https://mise.jdx.dev/bootstrap.html), [CLI](https://mise.jdx.dev/cli/bootstrap.html)).
- “Bootstrap is a sequence, not a transaction: if a later phase fails, earlier successful changes remain” ([bootstrap](https://mise.jdx.dev/bootstrap.html)).
- `--only` / `--skip` select parts; `--only` and `--skip` are mutually exclusive ([CLI](https://mise.jdx.dev/cli/bootstrap.html)).
- `mise bootstrap plan` currently covers a **subset** of the surface (accounts, system packages, privileged files/directories, system services, firewall, Compose). Docs say other parts will join the graph later ([bootstrap](https://mise.jdx.dev/bootstrap.html)). Dotfiles are inspected with `mise dot status` / `mise dot apply --dry-run`, not fully by `plan`.
- The CLI marks `mise bootstrap` as **“Effect: destructive — may delete or irreversibly overwrite”** ([CLI](https://mise.jdx.dev/cli/bootstrap.html)).

### 3.2 `[dotfiles]`: link / copy / template / edit / track

Each `[dotfiles]` key is a **target path** (`absolute` or `~/...`). Modes ([dotfiles](https://mise.jdx.dev/dotfiles.html)):

| Mode | Apply behavior | Default? |
| --- | --- | --- |
| `symlink` | One link to a file or entire directory | Yes (`dotfiles.default_mode`, default `symlink`) ([settings](https://mise.jdx.dev/configuration/settings.html#dotfiles.default%5Fmode)) |
| `symlink-each` | Create dirs and link each file; records links under `$MISE_STATE_DIR/dotfiles` | |
| `copy` | Copy file or directory, overwriting matching files | |
| `template` | Render source with Tera | |
| `track` | Leave the live file in place; checkpoint history | Separate workflow |

Additional whole-file options:

- Omit `source` → infer from `dotfiles.root` (default `~/.dotfiles`) using the path relative to `$HOME` ([dotfiles](https://mise.jdx.dev/dotfiles.html), [settings](https://mise.jdx.dev/configuration/settings.html#dotfiles.root)).
- Relative `source` is resolved from the **directory containing the config file**, not from `dotfiles.root`.
- `content = "..."` declares an inline file; cannot mix with `source`/`mode`/`exclude`/edit options. On Unix the result is mode **`0600`**.
- Source globs (`*`, `**`, `?`, `[ab]`) require matching wildcards in the target.
- Directory-walking modes take `exclude` globs; `manifest = "git"` limits walking to `git ls-files`.
- `variants` (since 2026.9.5) pick OS/arch/`profile` destinations, including a logical key when every variant supplies `target` ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

**Edit entries** (not whole files) are keyed `target/id` and write either:

- a **block** between `# >>> mise:id >>>` / `# <<< mise:id <<<` markers, or
- a **line** that is appended (or `position = "prepend"`) if missing.

Comment prefix is inferred from extension (`#`, `--` for Lua, `//`, `;`, `"` for vim). Strict JSON/XML are not block-friendly ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

Commands: `mise dot` is an alias of `mise dotfiles` and of `mise bootstrap dotfiles` ([dotfiles](https://mise.jdx.dev/dotfiles.html), [CLI](https://mise.jdx.dev/cli/dotfiles.html)).

### 3.3 Source / destination semantics vs chezmoi

| Concern | chezmoi (this repo) | mise `[dotfiles]` |
| --- | --- | --- |
| Source layout | Encoded filenames in one source dir (`dot_config/nvim` → `~/.config/nvim`) ([attributes](https://www.chezmoi.io/reference/source-state-attributes/)) | Literal sources; mapping declared in TOML. Default inference is `~/.zshrc` ← `~/.dotfiles/.zshrc` |
| Target files | Generated **regular files** by default; symlink mode is a special, limited opt-in ([design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)) | Default **symlink** |
| Templates | Go `text/template` + sprig; `.tmpl` suffix or `.chezmoitemplates` ([templating](https://www.chezmoi.io/user-guide/templating/)) | Tera v2; `mode = "template"` ([templates](https://mise.jdx.dev/templates.html)) |
| Permissions | `private_`, `executable_`, `readonly_` in the filename | Inherit source mode on template apply; inline `content` is `0600`; no `private_` equivalent |
| Ignore | Templated `.chezmoiignore` ([machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)) | `exclude` on directory entries; `variants`; `enabled = false` |
| Platform files | Ignore or template on `.chezmoi.os` (`darwin`/`linux`/…) | `variants.os` uses mise names (`macos`/`linux`/`windows`, optional `/arch`) |
| Removal | `remove_` attribute; empty template result deletes target | Removing a config entry **leaves the file**; need `mise dot unapply` first ([dotfiles](https://mise.jdx.dev/dotfiles.html)) |
| Directory leftovers | `exact_` can remove unmanaged children | Directory **copy is additive**; deleted/excluded sources leave copies. `symlink-each` removes recorded links |
| Isolated dest | `--destination` (used in this repo’s CI) | Not documented for `mise dot apply` |
| Outside `$HOME` | Discouraged; scripts/`destDir` ([design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)) | `[dotfiles]` is user-owned (no sudo). Privileged paths are `[bootstrap.files]` ([files](https://mise.jdx.dev/bootstrap/files.html), [dotfiles](https://mise.jdx.dev/dotfiles.html#root-owned-files)) |

chezmoi `private_` is **not encryption**. Official attribute table: `private_` “Remove all group and world permissions from the target file or directory”; `encrypted_` is a separate prefix ([attributes](https://www.chezmoi.io/reference/source-state-attributes/)). This repo uses `private_` on `Library/…/Cursor`, `vale`, `jj`, `zed/settings.json`, and `~/.local/bin` helpers.

### 3.4 Templates

mise templates are **Tera v2** with extras (`os()`, `arch()`, `env`, `vars`, `exec()`, `read_file()`, `secret()`) ([templates](https://mise.jdx.dev/templates.html), [secrets](https://mise.jdx.dev/bootstrap/secrets.html)).

Important operational difference from chezmoi `diff`:

- `status`, `diff`, and `apply` **render templates to check output**, which **executes `exec()`** in those templates ([dotfiles](https://mise.jdx.dev/dotfiles.html)).
- `--dry-run` **skips rendering** dotfile templates and labels them `(if changed)`. Other config expressions can still run ([dotfiles](https://mise.jdx.dev/dotfiles.html)).
- `exec()` is documented as running even during `--dry-run` **of configuration templates** (not the skipped dotfile-template render) ([templates](https://mise.jdx.dev/templates.html)).
- Tera v1 compatibility helpers warn starting **2026.10.0** and are scheduled for removal in **2027.4.0** ([templates](https://mise.jdx.dev/templates.html)).

chezmoi templates have first-class `.chezmoi.os`, `.chezmoi.arch`, `.chezmoi.hostname`, `.chezmoi.homeDir`, kernel/os-release, and password-manager functions ([variables](https://www.chezmoi.io/reference/templates/variables/), [password managers](https://www.chezmoi.io/user-guide/password-managers/)). This repo’s only content template is:

```yaml
style: {{ joinPath .chezmoi.homeDir ".config" "glow" "catppuccin-mocha.json" | quote }}
```

A mise equivalent would be Tera plus `xdg_config_home` / `env.HOME`, not `.chezmoi.homeDir`.

### 3.5 Platform / condition handling

mise has several overlapping selectors; they are **not** the same as chezmoi’s `.chezmoi.os`:

| Mechanism | What it selects | Notes |
| --- | --- | --- |
| `[dotfiles].variants` `os` / `os/arch` / `profile` / `default` | Destination (or history stream, for `track`) | Most specific wins; ties are invalid ([dotfiles](https://mise.jdx.dev/dotfiles.html)) |
| `mise -E` / `MISE_ENV` / `.miserc.toml` `env` | Extra config files (`mise.work.toml`, `config.work.toml`) | Does not set app `NODE_ENV` unless you define it ([environments](https://mise.jdx.dev/configuration/environments.html)) |
| `auto_env` | Auto-load `mise.macos.toml`, `mise.linux.toml`, `mise.macos-arm64.toml` | **Disabled by default**; default becomes `true` in **2027.6.0**; must be set in `.miserc.toml` or `MISE_AUTO_ENV` ([environments](https://mise.jdx.dev/configuration/environments.html)) |
| `[tools].os` / `[bootstrap.packages].os` | Skip install on non-matching OS | Same name set: `linux`, `macos`, `windows` ([tools](https://mise.jdx.dev/dev-tools/), [packages](https://mise.jdx.dev/bootstrap/packages/)) |
| Template `os()` / `arch()` | String tests inside Tera | `os()` returns `linux`/`macos`/`windows` ([templates](https://mise.jdx.dev/templates.html)) |

chezmoi uses Go’s `runtime.GOOS`, so this repo’s ignore is `darwin`, not `macos` ([variables](https://www.chezmoi.io/reference/templates/variables/)). A mechanical port of `.chezmoiignore` would get that wrong.

`profile` variants plus `symlink-each` are explicitly intended as **home/work profile switches**: applying `-E home` vs `-E work` reconciles previously recorded links ([dotfiles](https://mise.jdx.dev/dotfiles.html)). This repo does not currently have a work/home split in chezmoi config files.

### 3.6 Secrets and security

**chezmoi (available, unused here):**

- Whole-file encryption with age/gpg/git-crypt/transcrypt (`encrypted_` + `chezmoi add --encrypt`) ([encryption](https://www.chezmoi.io/user-guide/encryption/)).
- Password-manager template functions (1Password, etc.) so a **public** repo can stay public ([password managers](https://www.chezmoi.io/user-guide/password-managers/), [setup](https://www.chezmoi.io/user-guide/setup/)).
- Local machine config `~/.config/chezmoi/chezmoi.toml` is not in the public source.

**mise:**

- `[bootstrap.secrets]` maps **logical names → environment variables**. Values are not stored in config. Intended provider boundary is something like [fnox](https://fnox.jdx.dev/), used as `fnox exec -- mise bootstrap` ([secrets](https://mise.jdx.dev/bootstrap/secrets.html)).
- Templates consume `{{ secret(name="logical_name") }}`. `secret()` inserts raw bytes; it does **not** quote/escape for the target format ([secrets](https://mise.jdx.dev/bootstrap/secrets.html)).
- Referenced secrets are resolved **before any full-bootstrap mutation**; unused declarations do not block ([bootstrap](https://mise.jdx.dev/bootstrap.html), [secrets](https://mise.jdx.dev/bootstrap/secrets.html)).
- Plans, dry-runs, status, and privileged-helper output **redact** secret values; there is no command to print them ([secrets](https://mise.jdx.dev/bootstrap/secrets.html)).
- `--prompt-secrets` prompts in memory and does not export ([secrets](https://mise.jdx.dev/bootstrap/secrets.html)).
- History encryption uses age recipients; **filenames stay visible**; live files stay plaintext; adding encryption later **does not erase earlier plaintext commits**, and a push is blocked until that history is rewritten ([history](https://mise.jdx.dev/history.html#encrypted-shared-files)).
- Default history exclusions: credential files and `*.local.toml` ([history](https://mise.jdx.dev/history.html)).
- Trust: tasks/hooks/some env directives execute code. `mise trust` is required in paranoid mode; otherwise commands that execute project behavior auto-trust the active config outside CI ([getting started](https://mise.jdx.dev/getting-started.html#trust)). `mise bootstrap --from` “trusts the repository you supply for this invocation” ([bootstrap](https://mise.jdx.dev/bootstrap.html)).
- `settings.experimental` still exists as a general beta gate ([settings](https://mise.jdx.dev/configuration/settings.html#experimental)); bootstrap/dotfiles are **not** documented as requiring it after 2026.6.6.
- Recent security-relevant changes: `history.describe_command` is **global-only** as of 2026.9.7 because a project config could have executed with unencrypted diffs ([v2026.9.7](https://github.com/jdx/mise/releases/tag/v2026.9.7)); `mise oci build` rejects `secret()` / `exec()` / `env` in dotfile templates so credentials are not baked into image layers (same release).

For **this public repo**, the important official warning is about tracking/sync, not about copy/symlink:

> Use a private repository: synchronization sends earlier checkpoints too, so temporary edits can become part of the shared history. ([dotfiles](https://mise.jdx.dev/dotfiles.html))

The 2026-09-07 post is more explicit: do not make the tracking origin public; deleting a secret later does not erase saved commits ([post](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/)).

### 3.7 Preview, idempotency, state

| Operation | chezmoi | mise |
| --- | --- | --- |
| Preview | `chezmoi diff`, `apply --dry-run --verbose` | `mise dot diff`, `mise dot apply --dry-run [--verbose]`, `mise bootstrap --dry-run`, `mise bootstrap plan` (partial) |
| Converged? | `chezmoi verify` (exit 1 on drift) ([verify](https://www.chezmoi.io/reference/commands/verify/)) | `mise dot status --missing` (exit 1); `mise bootstrap status --missing` |
| Conflict with existing files | Prompt if target changed since last write ([apply](https://www.chezmoi.io/reference/commands/apply/)) | Symlink: refuse without `--force`. Copy/template: **overwrite without `--force`**. Bootstrap default: refuse dotfile conflicts unless `--force-dotfiles` ([dotfiles](https://mise.jdx.dev/dotfiles.html), [bootstrap](https://mise.jdx.dev/bootstrap.html)) |
| Idempotency | Re-apply is a no-op when destination matches target state | Declarative steps skip unchanged state; hooks/task always run ([bootstrap](https://mise.jdx.dev/bootstrap.html)) |
| History of applies | chezmoi persistent state + your git repo | Every mutating apply/add/unapply/edit records a **pair of checkpoints** in `$MISE_STATE_DIR/history/repo.git` ([history](https://mise.jdx.dev/history.html), [bootstrap](https://mise.jdx.dev/bootstrap.html)) |
| Unapply | Manage `remove_` / stop managing + delete | `mise dot unapply`; modified copies need `--force`; leftover directory copies after source delete cannot be identified ([dotfiles](https://mise.jdx.dev/dotfiles.html)) |

Dry-run caveats that matter for this repo’s “preview before apply” culture:

- Dotfile template dry-runs **do not render**, so a glow.yml-style template would not be verified the way CI currently greps the rendered `style:` line ([dotfiles](https://mise.jdx.dev/dotfiles.html), `.github/workflows/check.yml`).
- `mise bootstrap --dry-run` still “inspects state”; remote dry-run still SSHs and stages ([remote](https://mise.jdx.dev/bootstrap/remote.html)).

Windows: `symlink` falls back to copy if Developer Mode is off; `symlink-each` **always copies** on Windows ([dotfiles](https://mise.jdx.dev/dotfiles.html#windows)).

### 3.8 Remote / bootstrap-from-repo

Three on-ramps ([bootstrap](https://mise.jdx.dev/bootstrap.html)):

| Flag | Repository contains | Checkout location |
| --- | --- | --- |
| `--from <url>` | A bootstrap **project** (`mise.toml` + sources) | `$MISE_DATA_DIR/bootstrap-repo` (override `--from-dir`) |
| `--adopt <url>` | Global mise config (`config.toml`, `conf.d/`, `tasks/`) | `$MISE_CONFIG_DIR` (usually `~/.config/mise`) |
| `--adopt <url>` on a **setup repo** (`.mise-history/format.toml`) | Tracked history from `mise dot origin set` | History store + restore live files, then bootstrap |

`--from` requires the existing checkout’s `origin` to match; `--update` fast-forwards only. With `--dry-run`, a missing checkout is reported and **not cloned** ([bootstrap](https://mise.jdx.dev/bootstrap.html)).

`mise bootstrap remote` applies a project over SSH using local OpenSSH ([remote](https://mise.jdx.dev/bootstrap/remote.html)):

- POSIX target with `cksum`, `mktemp`, `tar`, `uname`. Native Windows SSH/PowerShell targets are **not** supported.
- Local env vars are **not** copied; use `--prompt-secrets` or put secrets on the target.
- Optional read-only GitHub relay keeps tokens on the initiating machine; session-scoped; Linux/macOS only; no GitHub Enterprise ([remote](https://mise.jdx.dev/bootstrap/remote.html), [v2026.9.2](https://github.com/jdx/mise/releases/tag/v2026.9.2)).
- A compromised target can read authorized private content during the relay session (documented trust warning).

chezmoi’s equivalent new-machine line is `sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply $GITHUB_USERNAME` ([daily operations](https://www.chezmoi.io/user-guide/daily-operations/), [home](https://www.chezmoi.io)).

### 3.9 Interaction with tools / packages / services

Documented split ([bootstrap “what goes where”](https://mise.jdx.dev/bootstrap.html#what-goes-where), [packages](https://mise.jdx.dev/bootstrap/packages/)):

| Section | Owns |
| --- | --- |
| `[tools]` | Versioned **dev tools**, per-project, shims/PATH |
| `[bootstrap.packages]` | **Host** packages (apk/apt/dnf/pacman/aur/brew/brew-cask/flatpak/nix/mas/winget). Shared, no shims. Never installed implicitly by `mise install` |
| `[bootstrap.services]` | User services (Linux systemd --user, macOS LaunchAgent, Windows Scheduled Task); existing Linux system units |
| `[dotfiles]` | Home files |
| `[bootstrap.files]` | Absolute system paths, possibly root |
| `[tasks.bootstrap]` | Imperative leftover |

Nix-specific facts that collide with this repo’s ownership model ([nix packages](https://mise.jdx.dev/bootstrap/packages/nix.html)):

- `nix:` installs into the **user profile**, not a project toolset, and does not use sudo.
- `mise bootstrap packages export --format nix` can emit a NixOS `environment.systemPackages` module from shorthand `nix:` names.
- Apply vs export are different: apply mutates the user profile; export is for system config. Docs tell you not to do both for the same declarations.

This repository’s `AGENTS.md` already assigns packages/executables/shells/system settings to Nix/Home Manager. Neovim’s `NIXOS_SETUP.md` says LSP/formatters/linters are host-provisioned. Adding `[bootstrap.packages]` here would create a **second package owner**.

`mise install` / `mise bootstrap packages` **leave dotfiles alone**; only `mise bootstrap` (or `mise dot apply`) applies them ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

---

## 4. Maturity and limitations (as of 2026.9.7)

Timeline from official releases:

| Date | Version | Event |
| --- | --- | --- |
| 2026-06 (release 2026.6.6) | 2026.6.6 | First `mise bootstrap` + `[dotfiles]` (symlink/copy/template/edit) ([notes](https://github.com/jdx/mise/releases/tag/v2026.6.6)) |
| 2026-08-30 | 2026.8.15 | `mise dot diff`, `add --changed`, git manifests, profile source switches ([CHANGELOG](https://github.com/jdx/mise/blob/main/CHANGELOG.md)) |
| 2026-09-07 | 2026.9.2 | Rebuilt **track + history + origin sync**; GitHub SSH relay ([notes](https://github.com/jdx/mise/releases/tag/v2026.9.2)) |
| 2026-09-10 | 2026.9.5 | Platform **destination variants** |
| 2026-09-13 | 2026.9.7 | `dot conflicts`; secrets in dotfile templates; `describe_command` locked to global config |

Implications:

- The whole bootstrap/dotfiles product is **~3 months old**. Tracking/sync is **one week old** at the time of this note.
- CHANGELOG shows bootstrap/dotfiles patches in most 2026.6–2026.9 releases (destination variants, nix packages, `--adopt` naming, prepend lines, secrets, conflicts, history store internals). Expect churn.
- `mise bootstrap plan` is explicitly incomplete ([bootstrap](https://mise.jdx.dev/bootstrap.html)).
- `auto_env` (automatic `mise.macos.toml`) is still off by default until **2027.6.0** ([environments](https://mise.jdx.dev/configuration/environments.html)).
- GitHub Issues are **not used for new reports**; support is Discussions ([README](https://github.com/jdx/mise)).
- Local mise 2026.5.12 predates the feature. Any experiment requires upgrading mise first (and pinning `min_version`).

chezmoi, by contrast, is a 2.x single-purpose tool (docs latest 2.72.2) whose source-state representation is treated as a **backwards-compatible contract** ([design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)). This repo already pins 2.70.4 in CI.

---

## 5. Concrete fit for *this* repository

### 5.1 What would map cleanly

- Large trees that are identical on every machine (`dot_config/nvim`, kitty, lazygit, starship.toml) as `mode = "symlink"` or `"copy"` of a directory.
- The two `executable_*` scripts as copies/links of files that already have the executable bit in git (mise does not need an `executable_` prefix if the source mode is `0755`).
- macOS-only Cursor files via `variants` targeting `~/Library/Application Support/Cursor/User/...` vs skipping on Linux ([dotfiles variants](https://mise.jdx.dev/dotfiles.html#platform-specific-destinations)).
- Glow as `mode = "template"` with Tera, plus a copy of `catppuccin-mocha.json`.
- Optional `block`/`line` edits if you ever wanted mise to inject `eval "$(mise activate zsh)"` into a shell rc that Nix owns — but Nix already owns shells.

### 5.2 What would not map cleanly

1. **Filename encoding.** Every `dot_`, `private_`, `executable_` path would become either (a) a TOML map from target → source, or (b) a renamed tree under `dotfiles.root`. There is no chezmoi-compatible prefix parser.
2. **`.chezmoiignore` as a template.** Ignore of `Library/` on non-Darwin, plus unmanaged `.aws`/btop/Amp, would become `exclude`, `variants`, and “do not declare the entry.” Easy to get wrong; CI currently proves the Darwin-only Library behavior by applying on Ubuntu (Library must not appear).
3. **`private_` permissions.** chezmoi will chmod `0600`/`0700` from the prefix even if git does not store those bits ([attributes](https://www.chezmoi.io/reference/source-state-attributes/), [design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/) — git does not persist group/world bits). mise copy/symlink inherit whatever mode is in the tree; only inline `content` forces `0600`. Zed `private_settings.json` and Cursor settings would need explicit mode handling or a post-apply hook.
4. **Public repo + track/history.** Official guidance is private origin, because checkpoints include earlier file versions ([dotfiles](https://mise.jdx.dev/dotfiles.html), [history](https://mise.jdx.dev/history.html)). Enabling `mise dot origin set` against this GitHub repo would be a secret-leakage design error even if current files are clean.
5. **Isolated CI.** `.github/workflows/check.yml` uses `HOME="$RUNNER_TEMP/chezmoi home"` and `chezmoi --destination "$HOME" apply` then `verify`, then greps rendered glow.yml. `mise dot apply` has no `--destination` flag ([apply CLI](https://mise.jdx.dev/cli/dotfiles/apply.html)). Recreating this would mean either applying into the runner’s real home (unacceptable) or inventing an undocumented HOME/XDG sandbox and hoping templates resolve the same way.
6. **Nix ownership.** `[bootstrap.packages]`, `[bootstrap.mise_shell_activate]`, and `[bootstrap.user].login_shell` overlap Home Manager. Export-to-NixOS is a one-way dump of shorthand names, not a replacement for the existing nix-config repo ([nix](https://mise.jdx.dev/bootstrap/packages/nix.html)).
7. **Empty `dot_config/mise/`.** If chezmoi continues to manage `~/.config/mise` as an empty directory while mise also writes `config.toml` there, you get ownership fights. Self-managing-config is documented as an **advanced, careful** pattern ([bootstrap](https://mise.jdx.dev/bootstrap.html#advanced-self-managing-config)).
8. **Directory copy leftovers.** If nvim were `mode = "copy"` of a directory, deleting a plugin spec in git would **not** remove the target file ([dotfiles](https://mise.jdx.dev/dotfiles.html)). chezmoi without `exact_` has a similar additive default, but this repo’s operators already think in chezmoi `apply`/`verify`.
9. **Template dry-run gap.** CI’s glow assertion requires a real render. mise `--dry-run` would not catch a broken Tera template ([dotfiles](https://mise.jdx.dev/dotfiles.html)).
10. **Upgrade tax.** Workflow written against 2026.9.7 will not run on 2026.5.12; `min_version` would have to be hard-pinned, and every machine (including Nix-packaged mise) upgraded.

### 5.3 Migration patterns (if ever)

**Pattern A — keep chezmoi, ignore mise for files (recommended default).**
Continue the current source layout. If a machine needs mise at all, install it via Nix/Home Manager and keep `~/.config/mise/config.toml` **out of this public repo** (or gitignore local overlays). Matches current empty `dot_config/mise/` and the “Nix owns executables” rule.

**Pattern B — complement: mise tools only, chezmoi files.**
A *private* or machine-local `~/.config/mise/config.toml` declares `[tools]` / tasks. This public repo stays chezmoi. Bootstrap, if used, `--skip dotfiles` and does not declare `[bootstrap.packages]` that Nix already provides.

**Pattern C — complement: mise applies a few files, chezmoi keeps the rest.**
High conflict risk (two writers for `$HOME`). Only makes sense for files chezmoi currently ignores. Not worth it for nvim.

**Pattern D — replace chezmoi with `[dotfiles]` copy/symlink (not track).**
Rename `dot_config/` → `config/` (or keep sources next to `mise.toml` and list every target). Use `symlink` for nvim, `copy` for apps that rewrite files, `template` for glow, `variants` for Cursor. Rewrite CI without `--destination`. Drop `.chezmoiignore` templates. Keep the GitHub repo public. **Do not** enable history origin on it. This is a full rewrite of layout, CI, and operator docs for little gain: this repo barely uses templates/secrets/scripts, so chezmoi’s extra power is unused *and* its layout/CI are already paid for.

**Pattern E — replace with track + private origin.**
This is the workflow mise now documents first ([setup](https://mise.jdx.dev/bootstrap/setup.html)). It is the **wrong** model for a public, reviewable, CI-rendered source tree: live `$HOME` becomes the working copy; Git history of configs lives in `$MISE_STATE_DIR/history/repo.git`; the public repo would no longer be the source of truth. Conflicts with `AGENTS.md` (“edit source names such as `dot_config/...`; do not edit rendered files in `$HOME`”).

**Pattern F — `mise bootstrap --from` this repo as a bootstrap *project*.**
Would require adding a `mise.toml` at the repo root that mise trusts and applies. Combined with Pattern D. Still does not give isolated-destination CI.

---

## 6. Should mise replace, complement, or only bootstrap?

| Option | Verdict for this repo |
| --- | --- |
| **Replace chezmoi** | No. Public prefix-mapped source + isolated apply/`verify` CI is chezmoi’s home ground. mise’s advertised happy path is now in-place tracking to a private origin. Feature is <4 months old and still changing weekly. |
| **Complement** | Yes, narrowly: mise as the **tool/version** CLI (if Nix is not already covering a given runtime), maybe `mise run` tasks, maybe remote bootstrap of *machines* that then still run `chezmoi init --apply`. Do not dual-write the same files. |
| **Only installation/bootstrap** | Best complement if a non-Nix machine needs a one-shot: `curl https://mise.run \| sh` then `mise bootstrap --from … --skip packages` is still a worse new-machine story here than `chezmoi init --apply`, because the files are already chezmoi-shaped. Using mise only to install **mise itself** and language tools, then letting chezmoi apply, is coherent. |

chezmoi’s own comparison table does not include mise (it compares Stow/dotbot/rcm/vcsh/yadm/bare git) ([comparison](https://www.chezmoi.io/comparison-table/)). The mise author’s comparison treats chezmoi as “generated files, git on command, manual two-way sync” vs mise tracking as “regular files, auto git, auto two-way sync” ([post](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/)). That is accurate — and it is not this repo’s desired operating model.

---

## 7. Proposed minimal proof of concept (not implemented)

Goal: exercise **copy + template + darwin/macos variant** against *this* source tree **without** enabling tracking, history origin, or host packages. Requires mise **≥ 2026.9.7**.

Constraints the POC must obey:

- Do not `chezmoi apply` or write the real `$HOME` until explicitly requested.
- Do not `mise dot origin set` against this public remote.
- Do not declare `[bootstrap.packages]` / shell / login_shell.
- Keep chezmoi as the real manager; this `mise.toml` is an experiment only.

```toml
# Experimental only. Not part of the managed home layout.
# Requires: mise 2026.9.7+  (dotfile destination variants + template secrets API)
min_version = { hard = "2026.9.7" }

[settings]
# Explicit: we are not using ~/.dotfiles inference.
# Sources below are relative to this file (the chezmoi source root).
dotfiles.default_mode = "copy"

# Do not let a directory copy silently leave deleted files behind.
# Prefer listing files, not whole trees, in a POC.

[vars]
# Stand-in for .chezmoi.homeDir. Prefer env.HOME in templates if you
# ever sandbox HOME for CI.
glow_style = "{{ env.HOME }}/.config/glow/catppuccin-mocha.json"

[dotfiles."~/.config/starship.toml"]
source = "dot_config/starship.toml"
mode = "copy"

[dotfiles."~/.config/glow/catppuccin-mocha.json"]
source = "dot_config/glow/catppuccin-mocha.json"
mode = "copy"

[dotfiles."~/.config/glow/glow.yml"]
source = "dot_config/glow/glow.yml.tmpl"
mode = "template"

# Chezmoi encodes this as private_Library/... on darwin only.
# mise uses "macos", not "darwin".
[dotfiles."cursor/user-settings.json"]
source = "private_Library/private_Application Support/private_Cursor/User/settings.json"
mode = "copy"
variants = [
  { os = "macos", target = "~/Library/Application Support/Cursor/User/settings.json" },
]

[tasks.bootstrap]
description = "POC: never used. Kept empty so `mise bootstrap` does not run surprise commands."
run = "true"
```

A Tera rewrite of `glow.yml.tmpl` would replace `joinPath .chezmoi.homeDir ... | quote` with something like:

```
style: {{ vars.glow_style | json_encode }}
```

(or `env.HOME` joined with `join_path`). Do **not** keep Go-template syntax in a `mode = "template"` source.

Suggested dry-run loop, **after** upgrading mise, in a throwaway `HOME` if you later choose to run anything:

```sh
mise trust
mise dot apply --dry-run --verbose
mise dot diff
mise dot status
# stop here; do not apply to the real home
```

Success criteria for a later experiment (still not done here):

1. Dry-run mentions `starship.toml` and glow files only.
2. On Linux, Cursor settings are skipped (no `Library/` created).
3. Glow template is **not** fully validated by `--dry-run` (documented limitation); a real apply in an isolated home would be required to match current CI.
4. No `[history.origin]`, no watcher service, no packages.

If that experiment is ever done, keep it on a branch and leave `.github/workflows/check.yml` on chezmoi until mise grows an official isolated destination.

---

## 8. Sources

### mise (official)

- [https://mise.jdx.dev](https://mise.jdx.dev)
- [https://mise.jdx.dev/getting-started.html](https://mise.jdx.dev/getting-started.html)
- [https://mise.jdx.dev/bootstrap.html](https://mise.jdx.dev/bootstrap.html)
- [https://mise.jdx.dev/bootstrap/setup.html](https://mise.jdx.dev/bootstrap/setup.html)
- [https://mise.jdx.dev/bootstrap/files.html](https://mise.jdx.dev/bootstrap/files.html)
- [https://mise.jdx.dev/bootstrap/secrets.html](https://mise.jdx.dev/bootstrap/secrets.html)
- [https://mise.jdx.dev/bootstrap/packages/](https://mise.jdx.dev/bootstrap/packages/)
- [https://mise.jdx.dev/bootstrap/packages/nix.html](https://mise.jdx.dev/bootstrap/packages/nix.html)
- [https://mise.jdx.dev/bootstrap/remote.html](https://mise.jdx.dev/bootstrap/remote.html)
- [https://mise.jdx.dev/dotfiles.html](https://mise.jdx.dev/dotfiles.html)
- [https://mise.jdx.dev/history.html](https://mise.jdx.dev/history.html)
- [https://mise.jdx.dev/templates.html](https://mise.jdx.dev/templates.html)
- [https://mise.jdx.dev/configuration.html](https://mise.jdx.dev/configuration.html)
- [https://mise.jdx.dev/configuration/environments.html](https://mise.jdx.dev/configuration/environments.html)
- [https://mise.jdx.dev/configuration/settings.html](https://mise.jdx.dev/configuration/settings.html)
- [https://mise.jdx.dev/cli/bootstrap.html](https://mise.jdx.dev/cli/bootstrap.html)
- [https://mise.jdx.dev/cli/dotfiles.html](https://mise.jdx.dev/cli/dotfiles.html)
- [https://mise.jdx.dev/cli/dotfiles/apply.html](https://mise.jdx.dev/cli/dotfiles/apply.html)
- [https://github.com/jdx/mise](https://github.com/jdx/mise)
- [CHANGELOG](https://github.com/jdx/mise/blob/main/CHANGELOG.md)
- [v2026.6.6](https://github.com/jdx/mise/releases/tag/v2026.6.6)
- [v2026.9.2](https://github.com/jdx/mise/releases/tag/v2026.9.2)
- [v2026.9.7](https://github.com/jdx/mise/releases/tag/v2026.9.7)
- Author post: [Dotfiles That Save Themselves](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/) (2026-09-07)

### chezmoi (official)

- [https://www.chezmoi.io](https://www.chezmoi.io)
- [Setup](https://www.chezmoi.io/user-guide/setup/)
- [Daily operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [Templating](https://www.chezmoi.io/user-guide/templating/)
- [Machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [Encryption](https://www.chezmoi.io/user-guide/encryption/)
- [Password managers](https://www.chezmoi.io/user-guide/password-managers/)
- [Design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)
- [Source-state attributes](https://www.chezmoi.io/reference/source-state-attributes/)
- [Template variables](https://www.chezmoi.io/reference/templates/variables/)
- [`apply`](https://www.chezmoi.io/reference/commands/apply/)
- [`diff`](https://www.chezmoi.io/reference/commands/diff/)
- [`verify`](https://www.chezmoi.io/reference/commands/verify/)
- [Comparison table](https://www.chezmoi.io/comparison-table/)
