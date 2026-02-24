{
  flake.nixosModules.base = {...}: {
    config = {
      services.tailscale.enable = true;
    };
  };

  flake.nixosModules.dns-server = {
    config,
    lib,
    namespace,
    ...
  }: {
    options.${namespace}.tailscale = {
      tailnet = lib.mkOption {
        type = lib.types.str;
        description = "Your tailnet name";
      };
    };
    config = let
      cfg = config.${namespace}.tailscale;
    in {
      networking.search = ["${cfg.tailnet}.ts.net"];
      services.blocky.settings = {
        # https://tailscale.com/docs/reference/quad100
        conditional.mapping."ts.net" = "100.100.100.100";
      };
    };
  };
}
