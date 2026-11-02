{...}: let
  NIXOS_REPO = "/etc/nixos";
in {

  flake-file.inputs = {
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.homeModules.base = {
    config = {
      home.sessionVariables = {
        inherit NIXOS_REPO;
        NH_OS_FLAKE = NIXOS_REPO;
      };
    };
  };

  flake.nixosModules.base = {
    inputs,
    pkgs,
    username,
    ...
  }: {
    imports = [
      inputs.nix-index-database.nixosModules.default
    ];

    config = {
      programs.nix-index.package = inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-small-db;
      programs.nix-index-database.comma.enable = true;

      systemd.tmpfiles.settings."10-nixos-directory" = let
        permissions = {
          user = username;
          group = username;
          mode = "0755";
        };
      in {
        "/etc/nixos".d = permissions;
        "/persist/etc/nixos".d = permissions;
      };

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operator"
      ];

      nix.settings.trusted-users = ["@wheel"];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
  };

  flake.nixosModules.storage = {
    config,
    namespace,
    ...
  }: let
    cfg = config.${namespace}.storage.persist;
  in {
    config = {
      preservation.preserveAt."${cfg.mountpoint}".directories = [
        NIXOS_REPO
      ];
    };
  };
}
