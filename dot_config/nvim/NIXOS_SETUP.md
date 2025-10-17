# NixOS Setup Guide for Neovim Configuration

This configuration uses a **hybrid approach** for cross-platform compatibility:
- **NixOS**: LSPs and tools managed via Nix packages
- **macOS/Other**: LSPs and tools managed via Mason

## Quick Start

### 1. Import the NixOS Module

Add to your `home-manager` configuration:

```nix
# In your home.nix or flake.nix home-manager configuration
{
  imports = [
    # ... your other imports
    ./dot_config/nvim/neovim.nix  # Adjust path as needed
  ];
}
```

### 2. Rebuild Your System

```bash
# For home-manager standalone
home-manager switch

# For NixOS with home-manager as a module
sudo nixos-rebuild switch
```

### 3. Start Neovim

```bash
nvim
```

On first launch:
- **NixOS**: Will use system-provided LSPs (you'll see "NixOS detected: using system LSPs")
- **macOS**: Will download and install LSPs via Mason

## Architecture

### Platform Detection

The configuration detects NixOS by checking for `/etc/NIXOS`:

```lua
local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1
```

### LSP Setup Paths

#### On NixOS:
1. Mason plugins are **disabled** (never loaded)
2. `lspconfig` directly configures system LSPs
3. All LSPs/tools come from `neovim.nix`

#### On macOS:
1. Mason plugins **enabled** and loaded
2. Mason downloads binaries to `~/.local/share/nvim/mason/`
3. `mason-lspconfig` handles installation

## Included Packages

### LSP Servers (19 languages)
- `bash-language-server` - Bash/Shell
- `vscode-langservers-extracted` - CSS, HTML, JSON, ESLint
- `dockerfile-language-server-nodejs` - Docker
- `elixir-ls` - Elixir
- `gopls` - Go
- `graphql-language-service-cli` - GraphQL
- `lua-language-server` - Lua
- `nil` / `nixd` - Nix (choose one)
- `omnisharp` - C#
- `prisma` - Prisma ORM
- `pyright` - Python
- `rust-analyzer` - Rust
- `tailwindcss-language-server` - Tailwind CSS
- `taplo` - TOML
- `yaml-language-server` - YAML

### Formatters (10 tools)
- `prettier` / `prettierd` - JS/TS/CSS/HTML/JSON/YAML/Markdown
- `stylua` - Lua
- `black` + `isort` - Python
- `rustfmt` - Rust
- `nixpkgs-fmt` / `alejandra` - Nix
- `gofmt` (via go.nvim) - Go
- `csharpier` - C#

### Linters (6 tools)
- `eslint_d` - JavaScript/TypeScript
- `golangci-lint` - Go
- `hadolint` - Dockerfile
- `jsonlint` - JSON
- `tflint` - Terraform
- `vale` - Prose/Markdown

### Debug Adapters
- `delve` - Go debugger
- Note: Node.js debuggers still managed by Mason (vscode-js-debug)

### Additional Tools
- `lazygit` - Git TUI
- `ripgrep` - Fast grep
- `fd` - Fast file finder
- `deno` - For peek.nvim markdown preview
- `tree-sitter` - Parser generator
- Nerd Fonts - Icon support

## Customization

### Adding New LSP Servers

1. **Add to Nix config** (`neovim.nix`):
   ```nix
   extraPackages = with pkgs; [
     # ... existing packages
     my-new-lsp-server
     # Example for C#:
     # omnisharp-roslyn
   ];
   ```

2. **Add to Neovim LSP list** (`lua/plugins/lsp/init.lua`):
   ```lua
   local ensure_servers = {
     -- ... existing servers
     "my_new_server",
     -- Example: "omnisharp" for C#
   }
   ```

3. **Optional**: For complex server setup, create a dedicated plugin file:
   - See `lua/plugins/lsp/csharp.lua` for C# example
   - See `lua/plugins/lsp/go.lua` for Go example
   - See `lua/plugins/lsp/typescript.lua` for TypeScript example

4. Rebuild: `home-manager switch`

### Choosing Nix Formatters

The config includes both `nixpkgs-fmt` and `alejandra`. Choose one:

```nix
# Option 1: Keep both (alejandra is recommended)
alejandra
nixpkgs-fmt

# Option 2: Only alejandra (faster, opinionated)
alejandra

# Option 3: Only nixpkgs-fmt (official nixpkgs style)
nixpkgs-fmt
```

Update `conform.nvim` accordingly in `lua/plugins/style/autoformat.lua`.

### Per-Project LSP Overrides

Use `.nvim.lua` or `.nix` files in project root:

```lua
-- .nvim.lua in project root
vim.lsp.config.gopls.settings = {
  gopls = {
    buildFlags = {"-tags=integration"},
  }
}
```

## Troubleshooting

### LSP Not Starting on NixOS

1. **Check if LSP is in PATH:**
   ```bash
   which lua-language-server
   which gopls
   ```

2. **Verify notification:**
   ```vim
   :messages
   " Should see: "NixOS detected: using system LSPs"
   ```

3. **Check LSP status:**
   ```vim
   :LspInfo
   ```

4. **If missing, install the package:**
   ```nix
   # Add to neovim.nix extraPackages
   lua-language-server
   ```

### Mason Errors on NixOS

If you see Mason errors, it means the conditional loading failed:

```vim
:Lazy
" Mason plugins should show: "cond: false" on NixOS
```

If Mason is loading on NixOS:
1. Check `/etc/NIXOS` exists: `ls -la /etc/NIXOS`
2. Restart Neovim completely
3. Clear lazy.nvim cache: `rm -rf ~/.local/share/nvim/lazy`

### Formatters Not Working

1. **Check if formatter is installed:**
   ```bash
   which prettier
   which stylua
   ```

2. **Check conform.nvim status:**
   ```vim
   :ConformInfo
   ```

3. **Add missing formatter to `neovim.nix`**

### TypeScript/JavaScript Debugger

The `vscode-js-debug` adapter is complex to package in Nix. Solutions:

1. **Keep Mason for debug adapters only** (current setup)
2. **Manual install** of js-debug-adapter
3. **Use node2/chrome adapters** (already in config)

## File Structure

```
~/.config/nvim/
├── init.lua                    # Main config entry
├── lua/
│   └── plugins/
│       ├── lsp/
│       │   └── init.lua       # Hybrid LSP setup
│       ├── editor/
│       ├── git/
│       ├── style/
│       ├── testing/
│       └── ui/
├── neovim.nix                 # NixOS home-manager module
└── NIXOS_SETUP.md            # This file
```

## Platform-Specific Behavior

| Feature | NixOS | macOS |
|---------|-------|-------|
| LSP Installation | Nix packages | Mason |
| Formatter Installation | Nix packages | Mason |
| Linter Installation | Nix packages | Mason |
| Mason Plugins | Disabled | Enabled |
| Tree-sitter CLI | Nix package | Mason |
| System Integration | Native | Via Mason |

## Benefits of This Approach

1. **Reproducible on NixOS** - Declarative, version-controlled tools
2. **Works on macOS** - No NixOS required, Mason handles everything
3. **Single config** - Same `init.lua` works everywhere
4. **No FHS issues** - NixOS uses system paths, avoiding Mason's hardcoded paths
5. **Fast updates** - `nix flake update` for all tools at once

## Migration from Pure Mason

If migrating from a pure Mason setup:

1. Your config already works on macOS (no changes needed)
2. On NixOS:
   - Import `neovim.nix` to home-manager
   - Rebuild system
   - Delete `~/.local/share/nvim/mason` (optional cleanup)
3. All keybinds and features remain identical

## Support

- LSP issues: Check `:LspInfo` and `:checkhealth`
- Nix issues: Check `journalctl --user -u home-manager.service`
- Plugin issues: `:Lazy` and check individual plugin status
