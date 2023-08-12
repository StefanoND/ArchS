{ config, lib, pkgs, specialArgs, ... }:
let

  helpers = import ./helpers.nix {
    inherit pkgs;
    inherit lib;
    inherit config;
    inherit specialArgs;
  };

  nix-gaming = import (builtins.fetchTarball "https://github.com/fufexan/nix-gaming/archive/master.tar.gz");

in
{
  # Allow Proprietary packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = config.allowUnfreePredicate or (x: false);

      #allow insecure packages
      permittedInsecurePackages = [
        "openssl-1.1.1v"
        "electron-12.2.3"
      ];
    };
  };

  home.stateVersion = specialArgs.version; # Check flake.nix
  home.username = pkgs.config.username; # Check flake.nix
  home.homeDirectory = pkgs.config.home; # Check flake.nix
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = [
    pkgs.kate
    pkgs.cachix
    (helpers.nixGLVulkanNvidiaWrap pkgs.jdk17)
    #(helpers.nixGLVulkanNvidiaWrap nix-gaming.packages.${pkgs.system}.wine-ge)
    pkgs.winetricks
    #pkgs.wineWowPackages.staging
    #(helpers.nixGLVulkanNvidiaWrap nix-gaming.packages.${pkgs.system}.wine-osu)
    #pkgs.steam

    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

#    (nixgl.auto.nixGLNvidia.writeShellScriptBin "steam" ''
#      #!/bin/bash
#
#      ${nixgl.auto.nixGLNvidia}/bin/nixGLNVidia ${pkgs.steam}/bin/steam "$@"
#    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/111111/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Target is non-NixOS system
  targets.genericLinux.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Update Nix channels, when running home-manager switch, checks per-week
  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "weekly";
  };
  xdg = {
    enable = true; # Enable xdg
    mime.enable = true; # Rebuild .desktop file database for app launcher menus
  };
}
