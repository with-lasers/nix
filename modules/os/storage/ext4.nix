{
  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    username,
    ...
  }: let
    inherit (config.${namespace}) storage;
    inherit (storage) ext4;
    mountpoint =
      if ext4.enable
      then ext4.mountpoint
      else storage.persist.mountpoint;
  in {
    options.${namespace}.storage.ext4 = lib.mkOption {
      description = "ext4 persistence configuration.";
      default = {};
      type = lib.types.submodule ({...}: {
        options = {
          enable = lib.mkEnableOption "ext4 persistence";

          size = lib.mkOption {
            type = lib.types.str;
            default = "100G";
            description = "partition size for ext4 persistence.";
          };

          mountpoint = lib.mkOption {
            description = "Mountpoint for ext4 persistence.";
            type = lib.types.str;
            default = "/persist/ext4";
          };

          directories = lib.mkOption {
            description = "Directories stored on ext4 persistent storage.";
            type = lib.types.listOf lib.types.str;
            default = [
              "/var/lib/containers"
              "/var/lib/kubelet"
              "/var/lib/machines"
              "/var/lib/microvms"
              "/var/lib/rancher/k3s"
              "/var/lib/portables"
              "/var/lib/incus"
            ];
          };
        };
      });
    };

    config = lib.mkIf storage.persist.enable {
      fileSystems."${mountpoint}".neededForBoot = true;
      preservation.preserveAt."${mountpoint}".directories = ext4.directories;
    };
  };
}
