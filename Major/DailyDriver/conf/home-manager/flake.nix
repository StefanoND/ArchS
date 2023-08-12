{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:guibou/nixGL";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixgl, nixpkgs, flake-utils, nix-gaming, home-manager, ... }:
    let
      version = "23.05";
      username = "111111";
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      linux_home = "/home/${username}";
      path_to_dotfiles = "/.apps/archs/home-manager";

    in {
      homeConfigurations."111111" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.home = linux_home;
          config.allowUnfree = allowUnfree;
          config.allowUnfreePredicate = allowUnfreePredicate;
          config.username = username;
          overlays = [ nixgl.overlay ];
        };
        extraSpecialArgs = {
          version = version;
          path_to_dotfiles = "${linux_home}${path_to_dotfiles}";
        };
        modules = [
          ./home.nix
          ./dev.nix
          ./gaming.nix
        ];
      };
      nativeBuildInputs = [
        #hexdump
        #perl
        #python3
        #wineWowPackages.stable
      ];
      nix.settings = {
        substituters = ["https://nix-gaming.cachix.org"];
        trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
      };
      programs.gamemode = {
        enable = true;
        settings.general.inhibit_screensaver = 0;
      };
    };
}
