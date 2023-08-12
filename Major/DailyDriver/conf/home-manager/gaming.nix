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
    # import the low latency module
    imports = [
      #"${nix-gaming}/modules/pipewireLowLatency.nix"
    ];

    nixpkgs = {
      config = {
        allowUnfree = config.allowUnfree or false;
        allowUnfreePredicate = config.allowUnfreePredicate or (x: false);
      };
    };

    home.stateVersion = specialArgs.version;
    home.username = pkgs.config.username;
    home.homeDirectory = pkgs.config.home;

    home.packages = [
      pkgs.nixgl.auto.nixGLNvidia
      pkgs.nixgl.auto.nixVulkanNvidia
      pkgs.gamemode
      pkgs.mangohud
      (helpers.nixGLVulkanNvidiaWrap pkgs.steam)
      (helpers.nixGLVulkanNvidiaWrap pkgs.lutris)
      (helpers.nixGLVulkanNvidiaWrap pkgs.retroarchFull)
      (helpers.nixGLVulkanNvidiaWrap pkgs.gamescope)
      #(helpers.nixGLVulkanNvidiaWrap nix-gaming.packages.${pkgs.system}.osu-stable) # Testing
    ];

    programs = {
      home-manager.enable = true;
    };
  }
