# dotfiles
my current dotfiles

## Installation

### Option 1: Nix with Home Manager (Recommended)

The easiest and most reproducible way to set up these dotfiles is using Nix with Home Manager:

#### Prerequisites
1. Install Nix (with flakes support):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Enable flakes by adding to `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```

#### Quick Setup
```bash
cd ./dotfiles
./install-nix.sh
```

#### Manual Setup
```bash
# Install Home Manager and apply configuration
nix run nixpkgs#home-manager -- switch --flake .#max-vev

# Or if you prefer the traditional approach
nix run nixpkgs#home-manager -- switch -f home.nix
```

#### Managing Your Configuration
- Update packages: `home-manager switch --flake .#max-vev`
- Add new packages: Edit `home.nix` and run the update command
- Check what's installed: `home-manager packages`

### Option 2: Traditional Method (Homebrew + Stow)

#### Requirements

to install this configuration, the packages required are : **stow, git, nvim, homebrew**
also download any nerdfont (firacode is cool)

```bash
sudo apt install stow git neovim
```

to install [homebrew](https://docs.brew.sh/Homebrew-on-Linux)
```bash
sudo apt-get install build-essential procps curl file git
```

#### Usage

commands to create the symlinks to the config files 

```bash
cd ./dotfiles
stow -t ~/.config .config
```

### What's Included

The Nix configuration includes:
- **Shell**: zsh, fish, oh-my-posh, zoxide
- **Editor**: Neovim with full LSP setup
- **Development**: Node.js, Python, Rust, Go, Java
- **Tools**: git, ripgrep, fd, fzf, lazygit, jujutsu
- **Cloud**: Docker, Terraform, AWS CLI
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono, Hack)
