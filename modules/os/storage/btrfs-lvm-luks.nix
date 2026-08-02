{...}: {
  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    username,
    ...
  }: let
    cfg = config.${namespace}.storage;

    subvolumes = lib.mkMerge (lib.flatten [
      (lib.mapAttrsToList
        (
          mountpoint: v: let
            inferredSubvol =
              if mountpoint == "/"
              then "@"
              else "@" + (lib.removePrefix "/" mountpoint);
            subvol =
              if v ? subvol && v.subvol != null
              then v.subvol
              else inferredSubvol;
          in
            if v.snapshot
            then (lib.btrfs.snapperLayout subvol mountpoint)
            else (lib.btrfs.subvolume {inherit subvol mountpoint;})
        )
        cfg.btrfs.subvolumes)
    ]);
  in {
    options.${namespace}.storage.lvm-luks-btrfs = lib.mkOption {
      description = "LVM on LUKS configuration.";
      default = {};
      type = lib.types.submodule ({...}: {
        options = {
          enable = lib.mkEnableOption "";
          vg = lib.mkOption {
            type = lib.types.str;
            default = "pool";
            description = "The vg name.";
          };
        };
      });
    };

    config = lib.mkIf cfg.lvm-luks-btrfs.enable {
      ${namespace}.storage = {
        btrfs = {
          enable = true;
          subvolumes = {
            "/persist" = {snapshot = true;};
            "/" = {snapshot = true;};
            "/home" = {};
            "/home/${username}" = {snapshot = true;};
          };
        };
        ext4.enable = true;
      };

      preservation.preserveAt."/persist" = {
        directories = [
          "/var/log"
        ];
      };

      disko.devices = {
        disk.main = lib.fs.lvmOnLuks cfg.lvm-luks-btrfs.vg;
        lvm_vg.${cfg.lvm-luks-btrfs.vg} = {
          type = "lvm_vg";
          lvs = {
            main = {
              size = lib.mkDefault cfg.btrfs.size;
              content = {
                type = "btrfs";
                inherit subvolumes;
                postCreateHook = lib.btrfs.createSubvolumesScript subvolumes;
              };
            };

            ext4 = lib.mkIf cfg.ext4.enable {
              size = lib.mkDefault cfg.ext4.size;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = cfg.ext4.mountpoint;
              };
            };
          };
        };
      };

      virtualisation.vmVariantWithDisko = {
        disko.tests.extraConfig = {
          disko.devices.disk.main = {
            imageSize = "32G";
            content.partitions = {
              boot = lib.fs.partition.boot "1M";
              esp = lib.fs.partition.esp "128M";
              luks.content.preCreateHook = let
                luks = config.disko.devices.disk.main.content.partitions.luks;
              in ''
                # TODO: make a script with diskoImagesScript --pre-format-files
                # https://github.com/nix-community/disko/blob/master/docs/disko-images.md
                echo '${username}' > ${luks.content.passwordFile}
              '';
            };
          };
        };
      };
    };
  };
}
