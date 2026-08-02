# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "My public modules";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {config, ...}: {
        imports = [
          (inputs.import-tree ./modules)
        ];

        systems = import inputs.systems;
        _module.args.lib = inputs.nixpkgs.lib.extend (_: _: config.flake.lib);
      }
    );

  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
    preservation.url = "github:nix-community/preservation";
    systems.url = "github:nix-systems/default";
  };
}
