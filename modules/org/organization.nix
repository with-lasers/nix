{
  flake.nixosModules.organization = {
    config,
    lib,
    namespace,
    ...
  }: let
    cfg = config.${namespace}.organization;
  in {
    options.${namespace}.organization = {
      orgs = lib.mkOption {
        description = "Organizations materialized on this host.";
        type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
          options = {
            root = lib.mkOption {
              description = "Directory holding the projects of the organization.";
              type = lib.types.str;
              default = "/home/${name}/prj";
            };

            permissions = lib.mkOption {
              description = "Ownership and mode of the organization directories.";
              type = lib.types.submodule {
                options = {
                  user = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                  };

                  group = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                  };

                  mode = lib.mkOption {
                    type = lib.types.str;
                    default = "2770";
                  };
                };
              };

              default = {};
            };

            user.id = lib.mkOption {
              description = "uid and gid of the organization user.";
              type = lib.types.int;
            };
          };
        }));

        default = {};
      };
    };

    config = {
      ${namespace}.storage.btrfs.subvolumes =
        lib.mapAttrs' (name: _: lib.nameValuePair "/home/${name}" {snapshot = true;})
        cfg.orgs;

      systemd.tmpfiles.settings =
        lib.mapAttrs' (name: org: {
          name = "10-org-${name}";
          value = {
            "/home/${name}".d = {
              user = org.permissions.user;
              group = org.permissions.group;
              mode = "0770";
            };

            "${org.root}".d = org.permissions;
          };
        })
        cfg.orgs;
    };
  };
}
