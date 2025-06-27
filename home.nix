{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "max-vev";
  home.homeDirectory = "/Users/max-vev";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your environment.
  home.packages = with pkgs; [
    # Core system utilities
    git
    stow
    unzip
    curl
    wget
    
    # Shell and terminal utilities
    zsh
    fish
    starship
    oh-my-posh
    zoxide
    
    # Development tools - General
    neovim
    ripgrep
    fd
    fzf
    tree-sitter
    
    # Development tools - Languages and runtimes
    nodejs_20
    npm
    python3
    python311Packages.pip
    rustup
    go
    openjdk
    
    # Development tools - Language servers and formatters
    lua-language-server
    typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint_d
    nodePackages."@angular/cli"
    black  # Python formatter
    isort  # Python import sorter
    stylua # Lua formatter
    
    # Development tools - Build and Make
    gnumake
    cmake
    gcc
    
    # Cloud and Infrastructure
    docker
    docker-compose
    terraform
    awscli2
    
    # Version control and collaboration
    jujutsu
    
    # 1Password CLI (if available on your platform)
    _1password
    
    # Nerd Fonts for terminal
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
    
    # Additional utilities mentioned in your configs
    lazygit  # For the nvim snacks plugin
  ];

  # Home Manager can also manage your environment variables through 'home.sessionVariables'.
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
    # Java setup (matches your .zshrc)
    JAVA_HOME = "${pkgs.openjdk}";
    # Rust setup (matches your .zshrc)
    PATH = "$PATH:${pkgs.rustup}/bin";
  };

  # Programs configuration
  programs = {
    # Git configuration
    git = {
      enable = true;
      # Add your git config here if you want Home Manager to manage it
    };

    # Zsh configuration
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ 
          "git" 
          "sudo" 
          "command-not-found" 
          "aws" 
          "brew" 
          "colored-man-pages" 
          "zoxide" 
          "docker-compose" 
          "terraform" 
        ];
      };
      # You can add your custom .zshrc content here or source it
      initExtra = ''
        # Source your existing .zshrc if you want to keep using zinit
        if [ -f ~/.zshrc ]; then
          source ~/.zshrc
        fi
      '';
    };

    # Fish shell configuration
    fish = {
      enable = true;
    };

    # Neovim configuration
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    # Zoxide for better cd
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # Starship prompt (alternative to oh-my-posh if you want)
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # Direnv for project-specific environments
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # Symlink dotfiles using Home Manager
  home.file = {
    # Neovim configuration
    ".config/nvim".source = ./.config/nvim;
    
    # Fish configuration
    ".config/fish".source = ./.config/fish;
    
    # Oh My Posh configuration
    ".config/ohmyposh".source = ./.config/ohmyposh;
    
    # You can add other dotfiles here as needed
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Platform-specific configurations
  targets.darwin = {
    # macOS specific settings
    defaults = {
      # Add macOS defaults here if needed
    };
  };

  # Fonts
  fonts.fontconfig.enable = true;
}
