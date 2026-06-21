{inputs, ...}: {
  flake.homeModules.vscode = {
    config,
    lib,
    pkgs,
    inputs,
    namespace,
    ...
  }: {
    config.programs.vscode.package = pkgs.vscode.overrideAttrs (oldAttrs: rec {
      buildInputs =
        (oldAttrs.buildInputs or [])
        ++ [
          pkgs.xorg.libXtst
          pkgs.libjpeg8
          pkgs.pipewire
          pkgs.libei
        ];

      version = "1.125.1";
      src = pkgs.fetchurl {
        name = "VSCode_${version}_linux-x64.tar.gz";
        url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
        hash = "sha256-EZ3WDviY6hQJ+wFgq5UI6gn4rmxB0wWLk2rrAH4qsiM=";
      };
    });
  };
}
