{
  description = "Max's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For macOS support
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, darwin, ... }:
    let
      system = "aarch64-darwin"; # Change to "x86_64-darwin" for Intel Macs or "x86_64-linux" for Linux
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."max-vev" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      # For macOS systems using nix-darwin
      darwinConfigurations."max-macbook" = darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Your nix-darwin configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."max-vev" = import ./home.nix;
          }
        ];
      };
    };
}
