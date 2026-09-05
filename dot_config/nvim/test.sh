#!/usr/bin/env bash
# Quick smoke test for neovim config
# Usage: ./test.sh [--apply|--ci]
# --apply deploys the source first; --ci bootstraps plugins in an isolated XDG home.
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  echo "Neovim is required on PATH." >&2
  exit 1
fi

NVIM_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILED=0
CI_MODE=0
TEST_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/nvim-config-test.XXXXXX")"
cleanup() {
  rm -rf "$TEST_TMPDIR" 2>/dev/null || {
    sleep 1
    rm -rf "$TEST_TMPDIR"
  }
}
trap cleanup EXIT

run_nvim() {
  NVIM_LOG_FILE="$TEST_TMPDIR/nvim.log" nvim "$@"
}

if [[ "${1:-}" == "--apply" ]]; then
  echo "Running chezmoi apply..."
  chezmoi apply
elif [[ "${1:-}" == "--ci" ]]; then
  CI_MODE=1
  export XDG_CONFIG_HOME="$TEST_TMPDIR/config"
  export XDG_DATA_HOME="$TEST_TMPDIR/data"
  export XDG_STATE_HOME="$TEST_TMPDIR/state"
  export XDG_CACHE_HOME="$TEST_TMPDIR/cache"
  mkdir -p "$XDG_CONFIG_HOME"
  cp -R "$NVIM_DIR" "$XDG_CONFIG_HOME/nvim"
  NVIM_DIR="$XDG_CONFIG_HOME/nvim"
fi
export NVIM_CONFIG_TEST_LOCK="$TEST_TMPDIR/lazy-lock.json"
cp "$NVIM_DIR/lazy-lock.json" "$NVIM_CONFIG_TEST_LOCK"

echo "=== Neovim config smoke test ==="
echo ""

# 1. Parse check all Lua files
echo "--- Lua syntax check ---"
while IFS= read -rd '' f; do
  rel="${f#"$NVIM_DIR/"}"
  if ! run_nvim --clean --headless -c "lua if not loadfile([[$f]]) then vim.cmd('cquit') end" -c 'qa' </dev/null 2>/dev/null; then
    echo "FAIL $rel"
    FAILED=1
  else
    echo "ok   $rel"
  fi
done < <(find "$NVIM_DIR" -name '*.lua' -print0)

echo ""

# 2. CI starts with no plugin cache. A successful synchronous install proves
#    the lockfile resolves before the ordinary startup assertions run.
if [[ "$CI_MODE" == "1" ]]; then
  echo "--- Plugin bootstrap ---"
  if OUTPUT=$(run_nvim --headless -u "$NVIM_DIR/init.lua" -c 'Lazy! restore' \
    -c 'lua local ok, installed = pcall(function() return require("nvim-treesitter").install({ "javascript", "tsx" }):wait(300000) end); if not ok or not installed then vim.cmd("cquit") end' \
    -c 'qa' 2>&1); then
    echo "ok   lazy-lock.json resolves and smoke-test parsers install"
  else
    echo "FAIL plugin bootstrap"
    echo "$OUTPUT"
    FAILED=1
  fi
fi

# 3. Headless startup
echo "--- Startup check ---"
if OUTPUT=$(run_nvim --headless -u "$NVIM_DIR/init.lua" -c 'lua print("init ok")' -c 'qa' 2>&1) \
  && echo "$OUTPUT" | grep -q "init ok"; then
  echo "ok   startup"
else
  echo "FAIL startup"
  echo "$OUTPUT"
  FAILED=1
fi

# 4. Check core treesitter filetype aliases that have regressed before.
printf '%s\n' 'export default function App(){ return <div /> }' > "$TEST_TMPDIR/probe.tsx"
printf '%s\n' 'const el = <div />' > "$TEST_TMPDIR/probe.jsx"
for probe in "$TEST_TMPDIR/probe.tsx" "$TEST_TMPDIR/probe.jsx"; do
  rel="${probe##*/}"
  OUTPUT=$(run_nvim --headless -u "$NVIM_DIR/init.lua" "$probe" \
    -c 'lua local b=vim.api.nvim_get_current_buf(); print(vim.treesitter.highlighter.active[b] ~= nil and "active" or "inactive")' \
    -c 'qa' 2>&1)
  if echo "$OUTPUT" | grep -qx "active"; then
    echo "ok   treesitter $rel"
  else
    echo "FAIL treesitter $rel"
    echo "$OUTPUT"
    FAILED=1
  fi
done

# 5. Contracts that do not require plugin state.
for suite in architecture bigfile formatting project-tools vscode; do
  echo "--- $suite checks ---"
  if OUTPUT=$(NVIM_CONFIG_TEST_ROOT="$NVIM_DIR" run_nvim --clean -l "$NVIM_DIR/tests/$suite.lua" 2>&1); then
    echo "ok   $suite"
  else
    echo "FAIL $suite checks"
    echo "$OUTPUT"
    FAILED=1
  fi
done

# Exercise plugin APIs without touching real breakpoint state outside --ci.
if [[ "$CI_MODE" == "1" ]]; then
  echo "--- Locked plugin contracts ---"
  if OUTPUT=$(NVIM_CONFIG_TEST_ROOT="$NVIM_DIR" run_nvim --headless -u "$NVIM_DIR/init.lua" \
    -c 'lua local ok, err = pcall(dofile, vim.env.NVIM_CONFIG_TEST_ROOT .. "/tests/plugins.lua"); if not ok then print(err); vim.cmd("cquit") end' \
    -c 'qa!' 2>&1); then
    echo "ok   locked revisions, textobject mappings, completion keys, and breakpoint persistence"
  else
    echo "FAIL locked plugin contracts"
    echo "$OUTPUT"
    FAILED=1
  fi

  if OUTPUT=$(NVIM_CONFIG_TEST_ROOT="$NVIM_DIR" run_nvim --clean -l "$NVIM_DIR/tests/vscode-plugins.lua" 2>&1); then
    echo "ok   real VS Code plugin boundary and shared lock preservation"
  else
    echo "FAIL real VS Code plugin boundary"
    echo "$OUTPUT"
    FAILED=1
  fi
fi

# 6. LSP registration drift: every lsp/*.lua must be in the enable list in
#    lua/plugins/lsp/init.lua and documented in NIXOS_SETUP.md (rust-analyzer
#    is managed by rustaceanvim and has no lsp/ file, so the reverse
#    direction only warns on unknown names).
echo "--- LSP drift check ---"
ENABLE_LIST=$(sed -n '/local servers = {/,/^      }/p' "$NVIM_DIR/lua/plugins/lsp/init.lua" | grep -o '"[a-z_]*"' | tr -d '"')
for f in "$NVIM_DIR"/lsp/*.lua; do
  name="$(basename "$f" .lua)"
  if ! grep -qx "$name" <<< "$ENABLE_LIST"; then
    echo "FAIL lsp/$name.lua exists but '$name' is not in the vim.lsp.enable list"
    FAILED=1
  elif ! grep -q "\`$name\`" "$NVIM_DIR/NIXOS_SETUP.md"; then
    echo "FAIL '$name' enabled but not documented in NIXOS_SETUP.md"
    FAILED=1
  else
    echo "ok   lsp/$name.lua"
  fi
done
for name in $ENABLE_LIST; do
  if [ ! -f "$NVIM_DIR/lsp/$name.lua" ]; then
    echo "FAIL '$name' is enabled but lsp/$name.lua does not exist"
    FAILED=1
  fi
done

# 7. Check for error messages on startup
ERRORS=$(run_nvim --headless -u "$NVIM_DIR/init.lua" -c 'redir @a | silent messages | redir END | lua print(vim.fn.getreg("a"))' -c 'qa' 2>&1 | grep -iE 'error|Error|E[0-9]{3,4}:' || true)
if [[ -n "$ERRORS" ]]; then
  echo "FAIL startup messages contain errors:"
  echo "$ERRORS"
  FAILED=1
else
  echo "ok   no error messages"
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo "All checks passed."
else
  echo "Some checks failed."
  exit 1
fi
