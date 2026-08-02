{lib, ...}: {
  flake-file.inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.lib.fs = {
    partition = {
      boot = size: {
        inherit size;
        name = "boot";
        type = "EF02";
      };

      esp = size: {
        label = "EFI";
        name = "ESP";
        size = lib.mkDefault size;
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };

      lvmOnLuks = vg: size: {
        inherit size;
        content = {
          type = "luks";
          name = "crypt";
          settings.allowDiscards = true;
          passwordFile = "/tmp/luks.key";
          content = {
            type = "lvm_pv";
            inherit vg;
          };
        };
      };
    };

    lvmOnLuks = vg: {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = lib.fs.partition.boot "1M";
          esp = lib.fs.partition.esp "1G";
          luks = lib.fs.partition.lvmOnLuks "pool" "100%";
        };
      };
    };
  };
}
