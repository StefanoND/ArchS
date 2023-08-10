{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = { url = "github:guibou/nixGL"; };
  };

  outputs = { nixgl, nixpkgs, home-manager, ... }:
    let
      version = "23.05";
      username = "mjvmdd";
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      linux_home = "/home/${username}";
      path_to_dotfiles = "/home/${username}/.apps/archs";
    in {
      homeConfigurations."mjvmdd" = home-manager.lib.homeManagerConfiguration {
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
#          ./shared.nix
#          ./linux/link.nix
#          ./linux/dev.nix
#          ./linux/home.nix
#          ./linux/gui.nix
        ];
      };
    };
}
