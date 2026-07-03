#!/usr/bin/env bash
# Quick smoke test for neovim config
# Usage: ./test.sh [--apply]  (--apply runs chezmoi apply first)
set -euo pipefail

NVIM_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILED=0
TEST_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/nvim-config-test.XXXXXX")"
trap 'rm -rf "$TEST_TMPDIR"' EXIT

run_nvim() {
  NVIM_LOG_FILE="$TEST_TMPDIR/nvim.log" nvim "$@"
}

if [[ "${1:-}" == "--apply" ]]; then
  echo "Running chezmoi apply..."
  chezmoi apply
fi

echo "=== Neovim config smoke test ==="
echo ""

# 1. Parse check all Lua files
echo "--- Lua syntax check ---"
while IFS= read -rd '' f; do
  rel="${f#"$NVIM_DIR/"}"
  if ! run_nvim --clean --headless -c "lua assert(loadfile([[$f]]))" -c 'qa' 2>/dev/null; then
    echo "FAIL $rel"
    FAILED=1
  else
    echo "ok   $rel"
  fi
done < <(find "$NVIM_DIR/lua" "$NVIM_DIR/lsp" -name '*.lua' -print0 2>/dev/null)

echo ""

# 2. Headless startup
echo "--- Startup check ---"
OUTPUT=$(run_nvim --headless -u "$NVIM_DIR/init.lua" -c 'lua print("init ok")' -c 'qa' 2>&1)
if echo "$OUTPUT" | grep -q "init ok"; then
  echo "ok   startup"
else
  echo "FAIL startup"
  echo "$OUTPUT"
  FAILED=1
fi

# 3. Check core treesitter filetype aliases that have regressed before.
printf '%s\n' 'export default function App(){ return <div /> }' > "$TEST_TMPDIR/probe.tsx"
printf '%s\n' 'const el = <div />' > "$TEST_TMPDIR/probe.jsx"
for probe in "$TEST_TMPDIR/probe.tsx" "$TEST_TMPDIR/probe.jsx"; do
  rel="${probe##*/}"
  OUTPUT=$(run_nvim --headless -u "$NVIM_DIR/init.lua" "$probe" \
    -c 'lua local b=vim.api.nvim_get_current_buf(); print(vim.treesitter.highlighter.active[b] ~= nil and "active" or "inactive")' \
    -c 'qa' 2>&1)
  if echo "$OUTPUT" | grep -q "active"; then
    echo "ok   treesitter $rel"
  else
    echo "FAIL treesitter $rel"
    echo "$OUTPUT"
    FAILED=1
  fi
done

# 4. Check for error messages on startup
ERRORS=$(run_nvim --headless -u "$NVIM_DIR/init.lua" -c 'redir @a | silent messages | redir END | lua print(vim.fn.getreg("a"))' -c 'qa' 2>&1 | grep -iE 'error|Error|E[0-9]{3,4}:' || true)
if [[ -n "$ERRORS" ]]; then
  echo "WARN startup messages contain errors:"
  echo "$ERRORS"
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
