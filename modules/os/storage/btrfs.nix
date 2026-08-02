{lib, ...}: let
  types = {
    subvolume = lib.types.submodule ({name, ...}: {
      options = {
        snapshot = lib.mkEnableOption "snapshots";

        mountPath = lib.mkOption {
          type = lib.types.str;
          description = "Mount path for the subvolume.";
          default = name;
        };

        subvol = lib.mkOption {
          type = lib.types.str;
          description = "Subvolume name derived from the mount path.";

          default =
            if name == "/"
            then "@"
            else "@" + lib.replaceStrings ["/"] ["-"] (lib.removePrefix "/" name);

          defaultText = lib.literalExpression ''
            if name == "/"
            then "@"
            else "@" + lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" name)
          '';
        };
      };
    });
  };
  subvolume = {
    subvol,
    mountpoint,
    # TODO: maybe remove ssd by default (?)
    mountOptions ? ["defaults" "discard=async" "compress=zstd" "ssd" "noatime" "nodiratime"],
    extra ? {},
  }: {
    "${subvol}" =
      {
        inherit mountOptions;
        extraArgs = ["-p"];
        mountpoint = builtins.toPath mountpoint;
      }
      // extra;
  };
in {
  flake.lib.btrfs = {
    inherit subvolume;
    mkSubvolume = path: (subvolume {
      subvol = "@${lib.removePrefix "@" path}";
      mountpoint = "/${lib.removePrefix "/" path}";
    });

    snapperLayout = subvol: path:
      lib.mkMerge [
        (subvolume {
          inherit subvol;
          mountpoint = "${path}/.snapshots";
        })
        (subvolume {
          subvol = "${subvol}/live/snapshot";
          mountpoint = "${path}";
        })
      ];

    createSubvolumesScript = subvolumes: let
      forEach = values: f: lib.strings.concatStringsSep "\n" (map (v: f v) values);
      subvolumeWithSnapshot = let
        filter = _: v: v ? "" && lib.hasSuffix "/.snapshot" v.mountpoint;
        snapshots = builtins.attrValues (lib.attrsets.filterAttrs filter subvolumes);
      in
        map (v: v.mountpoint) snapshots;
    in ''
      MNTPOINT=$(mktemp -d)

      mount "/dev/pool/main" "$MNTPOINT" -o subvol=/
      trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT

      # ls -lahR $MNTPOINT
      # btrfs subvolume list $MNTPOINT
      # cd $MNTPOINT

      ${forEach subvolumeWithSnapshot (subvol: ''
        mkdir -p "$MNTPOINT/${subvol}/blank/snapshot"
      '')}

      ${forEach subvolumeWithSnapshot (subvol: ''
        btrfs subvolume snapshot -r "$MNTPOINT/${subvol}/live/snapshot" "$MNTPOINT/${subvol}/blank/snapshot"
      '')}
    '';
  };

  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    username,
    ...
  }: {
    options.${namespace}.storage.btrfs = lib.mkOption {
      description = "BTRFS configuration.";
      default = {};
      type = lib.types.submodule ({...}: {
        options = {
          enable = lib.mkEnableOption "BTRFS";

          size = lib.mkOption {
            type = lib.types.str;
            default = "100%FREE";
            description = "partition size for BTRFS.";
          };

          mountOptions = lib.mkOption {
            description = "BTRFS mount options.";
            type = lib.types.listOf lib.types.str;
            default = [];
          };

          subvolumes = lib.mkOption {
            description = "BTRFS subvolume definitions.";
            type = lib.types.attrsOf types.subvolume;
            default = {
              "/" = {snapshot = true;};
              "/nix" = {};
              "/persist" = {snapshot = true;};
            };
          };
        };
      });
    };

    config = {
      boot.supportedFilesystems.btrfs = true;
    };
  };
}
