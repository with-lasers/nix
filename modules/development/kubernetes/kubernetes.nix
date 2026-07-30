{inputs, ...}: {
  flake.homeModules.development = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: let
    toYAML = (pkgs.formats.yaml {}).generate;
    inferEnvironment = environments: name: let
      matches = builtins.filter (env: environments.${env}.match name) (builtins.attrNames environments);
    in
      if matches != []
      then builtins.head matches
      else null;

    hasAnySuffix = suffixes: name: builtins.any (s: lib.hasSuffix s name) suffixes;

    clusterSubmodule = lib.types.submodule ({name, ...}: {
      options = {
        environment = lib.mkOption {
          type = lib.types.str;
          default = let
            env = inferEnvironment config.${namespace}.environments name;
          in
            if env != null
            then env
            else throw "kubernetes.clusters.${name}: cannot infer environment, set it explicitly.";
          description = "Environment label (e.g. production, staging). Auto-detected from cluster name suffixes.";
        };
        tags = lib.mkOption {
          type = lib.types.attrs;
          description = "Cluster metadata";
          default = {};
        };

        settings = lib.mkOption {
          type = lib.types.attrs;
          description = "extra settings";
          default = {};
        };
      };
    });
  in {
    options.${namespace} = {
      environments = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {
          production = {
            short = "prd";
            match = hasAnySuffix ["-prd" "-prod"];
          };
          staging = {
            short = "stg";
            match = hasAnySuffix ["-stg" "-stage"];
          };
          development = {
            short = "dev";
            match = hasAnySuffix ["-dev" "-development"];
          };
          experimentation = {
            short = "exp";
            match = hasAnySuffix ["-exp"];
          };
        };
      };

      kubernetes.clusters = lib.mkOption {
        description = "Kubernetes cluster definitions keyed by context name.";
        type = lib.types.attrsOf clusterSubmodule;
        default = {};
      };
    };

    config = {
      ${namespace}.shell.aliases = {
        k = "kubectl";
      };

      home.file.".config/kubernetes/clusters.yaml".source = toYAML "kubernetes/clusters.yaml" {
        clusters = config.${namespace}.kubernetes.clusters;
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
