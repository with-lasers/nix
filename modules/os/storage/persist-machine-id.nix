{
  flake.nixosModules.storage = {
    config,
    lib,
    namespace,
    ...
  }: let
    cfg = config.${namespace}.storage.persist;
  in {
    config = lib.mkIf cfg.enable {
      preservation.preserveAt."/persist".files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];

      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
      systemd.services.systemd-machine-id-commit = {
        unitConfig.ConditionPathIsMountPoint = ["" "/persist/etc/machine-id"];
        serviceConfig.ExecStart = ["" "systemd-machine-id-setup --commit --root /persist"];
      };
    };
  };
}
