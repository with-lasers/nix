{
  inputs,
  lib,
  ...
}: {
  config.flake-file.description = "My public modules";
  config.flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";
  };

  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = {};
  };

  imports = [inputs.flake-parts.flakeModules.modules];
}
