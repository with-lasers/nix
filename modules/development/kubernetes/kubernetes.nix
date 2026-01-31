{...}: {
  flake.homeModules.development = {
    config,
    namespace,
    pkgs,
    ...
  }: {
    config = {
      ${namespace}.shell.aliases = {
        k = "kubectl";
      };
    };
  };
}
