{
  flake.nixosModules.dns-server = {
    config,
    lib,
    namespace,
    ...
  }: {
    options.${namespace}.blocky = {
      port = lib.mkOption {
        type = lib.types.port;
        description = "blocky port";
        default = 53;
      };
    };
    config = let
      cfg = config.${namespace}.blocky;
      coredns = config.${namespace}.coredns;
      corednsAddress = "${coredns.ip}:${builtins.toString coredns.port}";
    in {
      networking.nameservers = [coredns.ip];
      networking.firewall = {
        allowedTCPPorts = [cfg.port];
        allowedUDPPorts = [cfg.port];
      };

      networking.search = lib.mkBefore [
        "home.arpa"
      ];

      services.blocky = {
        enable = true;
        settings = {
          upstreams.groups.default = [corednsAddress];

          bootstrapDns = ["tcp+udp:${corednsAddress}"];
          conditional.mapping."home.arpa" = "${corednsAddress}";

          blocking = {
            clientGroupsBlock.default = ["ads"];
            denylists.ads = [
              "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/pro.txt"
              "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/gambling.txt"
            ];
          };

          prometheus = {
            enable = true;
            path = "/metrics";
          };
        };
      };
    };
  };
}
