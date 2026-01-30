{
  flake.homeModules.base = {
    config,
    lib,
    namespace,
    ...
  }: {
    options.${namespace} = {
      shell.aliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Shell aliases for bash and zsh";
      };
    };

    config = {
      programs.bash = {
        enable = true;
        shellAliases = config.${namespace}.shell.aliases;
      };

      programs.zsh = {
        enable = true;
        shellAliases = config.${namespace}.shell.aliases;
      };
    };
  };
}
