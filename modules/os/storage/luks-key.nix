{
  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    ...
  }: let
    cfg = config.${namespace}.storage;
  in {
    options.${namespace}.storage.luks-usb = lib.mkOption {
      description = ''
        Automatically mounts a FAT32 USB partition during the systemd initrd
        (stage 1) and uses a key file stored on it to unlock a LUKS device.
      '';

      type = lib.types.submodule ({...}: {
        options = {
          enable = lib.mkEnableOption "";

          device = lib.mkOption {
            type = lib.types.str;
            description = "The LUKS device.";
            default = "crypt";
          };

          file = lib.mkOption {
            type = lib.types.str;
            description = "The key file.";
            default = "luks.key";
          };

          mountpoint = lib.mkOption {
            type = lib.types.str;
            description = "Where the file is mounted.";
            default = "/key";
          };

          partLabel = lib.mkOption {
            type = lib.types.str;
            description = "The partlabel name.";
            default = "boot-${config.networking.hostName}";
          };

          timeout = lib.mkOption {
            type = lib.types.ints.positive;
            description = "The mount timeout.";
            default = 10;
          };
        };
      });
    };

    config = lib.mkIf cfg.luks-usb.enable {
      boot.initrd = let
        inherit (cfg.luks-usb) device file mountpoint partLabel timeout;
      in {
        supportedFilesystems.vfat = true;
        availableKernelModules = ["uas" "usbcore" "usb_storage" "usbhid"];

        luks.devices."${device}".keyFile = "${mountpoint}/${file}";

        systemd = {
          enable = true;
          services."systemd-cryptsetup@${device}" = {
            overrideStrategy = "asDropin";
            unitConfig = {
              RequiresMountsFor = [];
              WantsMountsFor = [mountpoint];
            };
          };

          mounts = [
            {
              what = "PARTLABEL=${partLabel}";
              where = mountpoint;
              options = "ro";
              type = "vfat";
              unitConfig = {
                DefaultDependencies = false;
                JobTimeoutSec = timeout;
              };
            }
          ];
        };
      };
    };
  };
}
