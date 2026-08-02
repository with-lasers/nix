{inputs, ...}: {
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    username,
    ...
  }: let
    cfg = config.${namespace}.storage.persist;

    fileSystems = {
      # /etc/ssh keys to sshd and sops-nix
      "${cfg.mountpoint}".neededForBoot = true;
      # /nix
      "/".neededForBoot = true;
    };
  in {
    imports = [
      inputs.preservation.nixosModules.default
    ];

    options.${namespace}.storage.persist = {
      enable = lib.mkEnableOption "persistence";
      mountpoint = lib.mkOption {
        description = "Mountpoint for persistence.";
        type = lib.types.str;
        default = "/persist";
      };
    };

    config = lib.mkIf cfg.enable {
      boot.initrd.systemd.enable = true;

      preservation.enable = true;

      # Configuring permission so Home Manager works
      systemd.tmpfiles.rules = ["d /home/${username} 0750 ${username} ${username} -"];

      # Persist paths (/persist and /nix)
      inherit fileSystems;

      preservation.preserveAt."${cfg.mountpoint}" = {
        directories = [
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];

        users.${username}.directories = [
          "/documents"
          "/downloads"
          "/public"
        ];
      };

      disko.tests.extraConfig = {
        virtualisation = {
          inherit fileSystems;
        };

        # disko user might not have sops-nix
        users.users.${username} = {
          hashedPasswordFile = lib.mkForce null;
          password = username;
        };
      };
    };
  };
}
