{
  flake.nixosModules.dns-server = {
    config,
    lib,
    namespace,
    ...
  }: {
    options.${namespace}.coredns = {
      ip = lib.mkOption {
        type = lib.types.str;
        description = "CoreDNS ip";
        default = "127.0.0.1";
      };
      port = lib.mkOption {
        type = lib.types.port;
        description = "CoreDNS port";
        default = 1053;
      };
      zoneFile = lib.mkOption {
        type = lib.types.path;
        description = "CoreDNS zone file";
      };
    };

    config = let
      cfg = config.${namespace}.coredns;
      port = builtins.toString cfg.port;
    in {
      services.coredns = {
        enable = true;
        extraArgs = [
          "-dns.port=${port}"
        ];

        config = ''
          .:${port} {
              local
              errors
              log
              cache 300
              forward . 1.1.1.1 1.0.0.1
          }

          home.arpa:${port} {
              errors
              log
              file ${cfg.zoneFile}
          }
        '';
      };
    };
  };
}
