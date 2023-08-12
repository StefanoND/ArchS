{ pkgs, lib, config, specialArgs, ... }:
let
  nixGLNvidiaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${lib.getExe pkgs.nixgl.auto.nixGLNvidia} $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

  nixGLVulkanWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${
         lib.getExe pkgs.nixgl.auto.nixVulkanNvidia
       } $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

  nixGLVulkanNvidiaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "${lib.getExe pkgs.nixgl.auto.nixGLNvidia} ${
         lib.getExe pkgs.nixgl.auto.nixVulkanNvidia
       } $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

  linkAppConfig = appConfig: {
    home.file = {
      ".config/${appConfig}" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${specialArgs.path_to_dotfiles}/.config/${appConfig}";
        recursive = true;
      };
    };
  };

in {
  nixGLNvidiaWrap = nixGLNvidiaWrap;
  nixGLVulkanWrap = nixGLVulkanWrap;
  nixGLVulkanNvidiaWrap = nixGLVulkanNvidiaWrap;
  linkAppConfig = linkAppConfig;
}
