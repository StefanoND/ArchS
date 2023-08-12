{ config, pkgs, lib, specialArgs, ... }:
let
  helpers = import ./helpers.nix {
    inherit pkgs;
    inherit lib;
    inherit config;
    inherit specialArgs;
  };

  nix-gaming = import (builtins.fetchTarball "https://github.com/fufexan/nix-gaming/archive/master.tar.gz");

in {
  nixpkgs = {
    config = {
      allowUnfree = config.allowUnfree or false;
      allowUnfreePredicate = config.allowUnfreePredicate or (x: false);

      #allow insecure packages
      permittedInsecurePackages = [
        "openssl-1.1.1v"
        "electron-12.2.3"
      ];
    };
  };

  home.stateVersion = specialArgs.version;
  home.username = pkgs.config.username;
  home.homeDirectory = pkgs.config.home;

  home.packages = [
    pkgs.vscodium
    pkgs.vscode-extensions.maximedenes.vscoq
    pkgs.jetbrains.rider
  ];

  programs.home-manager.enable = true;
}
