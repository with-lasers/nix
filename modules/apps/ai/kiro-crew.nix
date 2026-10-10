{inputs, ...}: {
  flake.nixosModules.kiro-crew = {
    lib,
    pkgs,
    username,
    ...
  }: let
    kirocrew_home = "/var/lib/kirocrew";
  in {
    config = {
      systemd.tmpfiles.rules = [
        "d ${kirocrew_home} 2770 ${username} ${username} -"
      ];

      virtualisation.oci-containers.containers.kiro-crew = {
        # the latest "stable" tag
        # TODO: configure renovate (?)
        image = lib.mkDefault "ghcr.io/kirodotdev/kirocrew:0.7.2";
        environment = {
          KIROCREW_TELEMETRY_DISABLED = "1";
        };

        # TODO: reverse proxy
        ports = [
          "0.0.0.0:5476:5476"
        ];

        volumes = [
          "${kirocrew_home}:/home/kirocrew"
        ];

        autoRemoveOnStop = false;
        extraOptions = [
          "--restart=unless-stopped"
        ];
      };
    };
  };
}
