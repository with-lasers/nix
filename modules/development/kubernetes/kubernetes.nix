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

  # TODO: import krewfile HM module
  # FIXME: krewfile module dependency on ssh because of the git ssh override
  flake.homeModules.krew = {
    config,
    namespace,
    pkgs,
    ...
  }: {
    config = {
      home.sessionVariables = {
        KREW_ROOT = "${config.home.homeDirectory}/.config/krew";
      };

      home.sessionPath = [
        "${config.home.sessionVariables.KREW_ROOT}/bin"
      ];
    };
  };
}
