{
  flake.nixosModules.organization = {
    lib,
    namespace,
    ...
  }: {
    options.${namespace}.profiles = lib.mkOption {
      description = "Users materialized by the organization module.";
      type = lib.types.attrsOf (lib.types.submodule {
        options.user = lib.mkOption {
          type = lib.types.submodule {
            options = {
              id = lib.mkOption {
                description = "uid and gid of the user.";
                type = lib.types.int;
              };

              email = lib.mkOption {
                description = "Contact address, also used for the account description.";
                type = lib.types.str;
              };
            };
          };
        };
      });

      default = {};
    };
  };
}
