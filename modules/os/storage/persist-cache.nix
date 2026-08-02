{
  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    username,
    ...
  }: let
    inherit (config.${namespace}) storage;
    inherit (storage) cache;
    mountpoint =
      if cache.mountpoint != null
      then cache.mountpoint
      else storage.persist.mountpoint;
    hasCustomMountpoint = mountpoint != storage.persist.mountpoint;
  in {
    options.${namespace}.storage.cache = lib.mkOption {
      description = "cache configuration.";
      default = {};
      type = lib.types.submodule ({...}: {
        options = {
          enable = lib.mkEnableOption "cache";

          mountpoint = lib.mkOption {
            description = "Mountpoint for cache persistence.";
            type = lib.types.str;
            default = "/mnt/cache";
          };

          directories = lib.mkOption {
            description = "Cached directories";
            type = lib.types.listOf lib.types.str;
            default = [
              "/var/cache"
            ];
          };

          userDirs = lib.mkOption {
            description = "Cached directories per user";
            type = lib.types.listOf lib.types.str;
            default = [
              ".cache"
              ".kube/cache"
              ".npm/cacache"
            ];
          };
        };
      });
    };

    config = lib.mkIf cache.enable {
      "${namespace}".storage.btrfs.subvolumes = lib.mkIf hasCustomMountpoint {
        "${mountpoint}".subvol = "@cache";
      };

      preservation.preserveAt."${mountpoint}" = {
        directories = cache.directories;
        users.${username}.directories = cache.userDirs;
      };
    };
  };
}
