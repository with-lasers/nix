{inputs, ...}: {
  flake-file.inputs = {
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosModules.base = {
    config,
    lib,
    pkgs,
    namespace,
    username,
    ...
  }: {
    imports = [
      inputs.nix-index-database.nixosModules.default
    ];

    options.${namespace}.nixos.repo = lib.mkOption {
      description = "Directory holding the NixOS flake checkout.";
      type = lib.types.str;
      default = "/etc/nixos";
    };

    config = let
      repo = config.${namespace}.nixos.repo;
      persisted = repo == "/etc/nixos";
      permissions = {
        user = username;
        group = username;
        mode = "0755";
      };
    in {
      programs.nix-index.package = inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-small-db;
      programs.nix-index-database.comma.enable = true;

      # Follow the option for every home-manager user.
      home-manager.sharedModules = [
        {
          home.sessionVariables = {
            NIXOS_REPO = repo;
            NH_OS_FLAKE = repo;
          };
        }
      ];

      systemd.tmpfiles.settings."10-nixos-directory" =
        {
          "${repo}".d = permissions;
        }
        // lib.optionalAttrs persisted {
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
    lib,
    namespace,
    ...
  }: let
    cfg = config.${namespace}.storage.persist;
    repo = config.${namespace}.nixos.repo;
  in {
    config = {
      preservation.preserveAt."${cfg.mountpoint}".directories =
        lib.mkIf (repo == "/etc/nixos") [repo];
    };
  };
}
