{...}: {
  flake.homeModules.development = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: let
    cfg = config.${namespace}.k9s;
    wrapper = pkgs.writeShellApplication {
      name = "k9s";
      runtimeInputs = with pkgs; [
        yq-go
        kubectl
      ];
      text = ''
        CONFIG_ROOT=$HOME/.config/k9s
        CONFIG_DIR="''${CONFIG_DIR:-$CONFIG_ROOT/config.d}"
        CLUSTERS_YAML="''${CLUSTERS_YAML:-$HOME/.config/kubernetes/clusters.yaml}"

        context=""
        args=()

        while [[ $# -gt 0 ]]; do
          case "$1" in
            --context)
              context="$2"
              args+=("--context" "$2")
              shift 2
              ;;
            *)
              args+=("$1")
              shift
              ;;
          esac
        done

        if [[ -z "$context" ]]; then
          context="$(kubectl config current-context)"
        fi

        if [[ -f "$CLUSTERS_YAML" ]]; then
          profile="$(yq -r "$(printf '.clusters.%s.settings.k9s-skin // ""' "$context")" "$CLUSTERS_YAML")"

          if [[ -n "$profile" ]]; then
            export K9S_CONFIG_DIR="$CONFIG_DIR/$profile"
            export K9S_SKIN="''${K9S_SKIN:-$profile}"
          fi
        fi

        exec ${lib.getExe pkgs.k9s} "''${args[@]}"
      '';
    };
  in {
    options.${namespace}.k9s.profiles = lib.mkOption {
      description = "Generate multiple K9S_CONFIG_DIRs";
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          contexts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Kubernetes contexts that use this k9s profile.";
            default = [];
          };

          name = lib.mkOption {
            type = lib.types.str;
            description = "Profile name";
            default = name;
          };

          dir = lib.mkOption {
            type = lib.types.str;
            description = "Profile directory.";
            default = ".config/k9s/config.d/${name}";
          };

          views = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
            description = "Optional views configuration for this profile.";
            default = null;
          };
        };
      }));
      default = {};
    };

    config = lib.mkIf (cfg.profiles != {}) {
      home.packages = [
        wrapper
      ];

      systemd.user.tmpfiles.rules =
        [
          "d  %h/.local/state/k9s/benchmarks 0755 - - - -"
          "d  %h/.local/state/k9s/screen-dumps 0755 - - - -"
          "d  %h/.config/k9s/config.d 0755 - - - -"
        ]
        ++ lib.flatten (lib.mapAttrsToList (_: profile: [
            "d  %h/${profile.dir} 0755 - - - -"
            "L+ %h/${profile.dir}/skins - - - - %h/.config/k9s/skins"
            "L+ %h/${profile.dir}/clusters - - - - %h/.local/share/k9s/clusters"
            "L+ %h/${profile.dir}/benchmarks - - - - %h/.local/state/k9s/benchmarks"
            "L+ %h/${profile.dir}/screen-dumps - - - - %h/.local/state/k9s/screen-dumps"
          ])
          cfg.profiles);

      home.file = lib.mapAttrs' (_name: profile:
        lib.nameValuePair "${profile.dir}/views.yaml" {
          source = (pkgs.formats.yaml {}).generate "k9s-views-${profile.name}.yaml" {
            views = profile.views;
          };
        }) (lib.filterAttrs (_: profile: profile.views != null) cfg.profiles);
    };
  };
}
