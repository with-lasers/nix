{lib, ...}: let
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
in {
  flake-file.inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.lib.fs = {
    inherit partition;
    lvmOnLuks = vg: {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = partition.boot "1M";
          esp = partition.esp "1G";
          luks = partition.lvmOnLuks vg "100%";
        };
      };
    };
  };
}
