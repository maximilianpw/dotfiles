#!/usr/bin/env bash
# Quick smoke test for neovim config
# Usage: ./test.sh [--apply]  (--apply runs chezmoi apply first)
set -euo pipefail

NVIM_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILED=0

if [[ "${1:-}" == "--apply" ]]; then
  echo "Running chezmoi apply..."
  chezmoi apply
fi

echo "=== Neovim config smoke test ==="
echo ""

# 1. Parse check all Lua files
echo "--- Lua syntax check ---"
for f in $(find "$NVIM_DIR/lua" "$NVIM_DIR/lsp" -name '*.lua' 2>/dev/null); do
  rel="${f#"$NVIM_DIR/"}"
  if ! nvim --headless -c "lua dofile('$f')" -c 'qa' 2>/dev/null; then
    echo "FAIL $rel"
    FAILED=1
  else
    echo "ok   $rel"
  fi
done

echo ""

# 2. Headless startup
echo "--- Startup check ---"
OUTPUT=$(nvim --headless -c 'lua print("init ok")' -c 'qa' 2>&1)
if echo "$OUTPUT" | grep -q "init ok"; then
  echo "ok   startup"
else
  echo "FAIL startup"
  echo "$OUTPUT"
  FAILED=1
fi

# 3. Check for error messages on startup
ERRORS=$(nvim --headless -c 'redir @a | silent messages | redir END | lua print(vim.fn.getreg("a"))' -c 'qa' 2>&1 | grep -iE 'error|Error|E[0-9]{3,4}:' || true)
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
