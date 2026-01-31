{inputs, ...}: {
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

  # FIXME: krewfile module dependency on ssh because of the git ssh override
  flake.homeModules.krew = {
    config,
    namespace,
    pkgs,
    ...
  }: {
    imports = [
      inputs.krewfile.homeManagerModules.krewfile
    ];

    config = {
      home.extraActivationPath = [pkgs.openssh];

      home.sessionVariables = {
        KREW_ROOT = "${config.home.homeDirectory}/.config/krew";
      };

      home.sessionPath = [
        "${config.home.sessionVariables.KREW_ROOT}/bin"
      ];

      programs.krewfile = {
        enable = true;
        krewRoot = "${config.home.homeDirectory}/.config/krew";
        plugins = [
          "krew"
          "ns"
          "ctx"
          "access-matrix"
          "oidc-login"
        ];
      };
    };
  };
}
