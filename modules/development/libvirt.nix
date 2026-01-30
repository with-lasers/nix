{
  flake.nixosModules.development = {
    config,
    lib,
    namespace,
    pkgs,
    username,
    ...
  }: {
    config = {
      users.users.${username} = {
        extraGroups = ["libvirtd"];
      };

      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    };
  };
}
