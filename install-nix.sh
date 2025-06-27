#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_color $BLUE "🏠 Setting up dotfiles with Home Manager..."

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    print_color $RED "❌ Nix is not installed. Please install Nix first:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
    exit 1
fi

print_color $GREEN "✅ Nix is installed"

# Check if we're using flakes
if ! nix --version | grep -q "2\.[4-9]\|[3-9]"; then
    print_color $YELLOW "⚠️  You might need to enable flakes in your Nix configuration"
    echo "Add the following to ~/.config/nix/nix.conf:"
    echo "experimental-features = nix-command flakes"
fi

# Install Home Manager if not already installed
if ! command -v home-manager &> /dev/null; then
    print_color $YELLOW "📦 Installing Home Manager..."
    nix run nixpkgs#home-manager -- switch --flake .#max-vev
else
    print_color $GREEN "✅ Home Manager is already installed"
fi

# Apply the configuration
print_color $BLUE "🔧 Applying Home Manager configuration..."
if [ -f flake.nix ]; then
    print_color $BLUE "Using flake configuration..."
    home-manager switch --flake .#max-vev
else
    print_color $BLUE "Using traditional configuration..."
    home-manager switch -f home.nix
fi

print_color $GREEN "🎉 Dotfiles setup complete!"
print_color $BLUE "📝 Next steps:"
echo "  1. Restart your terminal or run: exec \$SHELL"
echo "  2. Your dotfiles are now managed by Home Manager"
echo "  3. To update: home-manager switch --flake .#max-vev"
echo "  4. To add packages: edit home.nix and run the update command"

print_color $YELLOW "💡 Note: Some applications might need to be restarted to pick up new configurations"
