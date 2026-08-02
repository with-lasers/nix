{inputs, ...}: {
  flake-file.description = "My public modules";
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";
  };

  imports = [inputs.flake-parts.flakeModules.modules];
}
