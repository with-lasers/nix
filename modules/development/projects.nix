{
  flake.homeModules.development = {
    config,
    lib,
    pkgs,
    namespace,
    ...
  }: let
    cfg = config.${namespace};
  in {
    options.${namespace} = {
      projectRoots = lib.mkOption {
        description = ''
          Where should I search for projects
        '';
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };

    config = {
      home.sessionVariables = {
        PROJECT_ROOTS = lib.strings.concatStringsSep ":" cfg.projectRoots;
      };
    };
  };
}
