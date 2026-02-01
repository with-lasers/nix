{
  description = "My public modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    krewfile.url = "github:brumhard/krewfile";
    krewfile.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    home-manager,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [(inputs.import-tree ./modules)];
      systems = import inputs.systems;
    });
}
