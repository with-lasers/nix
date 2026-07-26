{
  flake.homeModules.development = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: let
    toml = pkgs.formats.toml {};
    cfg = config.${namespace}.granted;

    normalize = entry:
      if builtins.isString entry
      then {
        name = entry;
        settings = {};
        flags = [];
      }
      else
        entry
        // {
          settings = entry.settings or {};
          flags = entry.flags or [];
        };

    entries = lib.concatLists (
      lib.mapAttrsToList (
        url: registry:
          lib.concatLists (
            lib.mapAttrsToList (
              kind: group:
                map (
                  entry:
                    {
                      inherit url kind;
                    }
                    // normalize entry
                )
                group
            )
            registry.groups
          )
      )
      cfg.registry
    );

    registries = map (entry:
      {
        inherit (entry) url name;
        type = "git";
        path = "${entry.kind}/${entry.name}";
      }
      // entry.settings)
    entries;

    registryLookup =
      lib.foldl'
      lib.recursiveUpdate
      {}
      (map (e: {${e.kind}.${e.name} = {inherit (e) url flags;};}) entries);

    granted-config = toml.generate "granted-config.toml" (
      lib.recursiveUpdate
      cfg.settings
      {
        ProfileRegistry.Registries = registries;
      }
    );

    granted-registry-lookup =
      pkgs.writeText "granted/registry-lookup.json"
      (builtins.toJSON registryLookup);

    mkShellApp = {
      name,
      text,
      runtimeInputs ? [],
      completion ? (_: ""),
    }: {
      home.packages = [
        (pkgs.writeShellApplication {
          inherit name runtimeInputs;
          text =
            if builtins.isFunction text
            then text name
            else text;
        })
      ];

      home.file.".config/zsh/completions/_${name}".text =
        completion name;
    };

    script-name = "aws-add-credentials";
    groupType = lib.types.submodule {
      freeformType = lib.types.attrs;

      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Group name.";
        };

        settings = lib.mkOption {
          type = lib.types.attrs;
          default = {};
          description = "Merged into the Granted registry entry.";
        };

        flags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Extra flags passed to 'granted registry add'.";
        };
      };
    };

    registryType = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
      options = {
        url = lib.mkOption {
          type = lib.types.str;
          description = "Registry URL";
          default = name;
        };

        groups = lib.mkOption {
          default = {};
          description = "Groups by kind (e.g. roles, squads).";
          type = lib.types.attrsOf (
            lib.types.listOf (
              lib.types.oneOf [
                lib.types.str
                groupType
              ]
            )
          );
        };
      };
    }));
  in {
    options.${namespace}.granted = {
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {
          DefaultBrowser = "FIREFOX";
          CustomBrowserPath = lib.getExe pkgs.firefox;
          CustomSSOBrowserPath = "";
          Ordering = "";
          ExportCredentialSuffix = "";
          ProfileRegistry = {
            PrefixAllProfiles = false;
            PrefixDuplicateProfiles = true;
          };
        };
      };

      registry = lib.mkOption {
        default = {};
        type = registryType;
      };
    };

    config = lib.mkIf config.programs.granted.enable (lib.mkMerge [
      (mkShellApp {
        name = script-name;
        runtimeInputs = with pkgs; [
          granted
          jq
        ];
        text = name: ''
          if [[ $# -ne 2 ]]; then
            echo "usage: ${name} <kind> <name>"
            exit 1
          fi

          kind="$1"
          name="$2"

          info="$(
            jq -cer \
              --arg kind "$kind" \
              --arg name "$name" \
              '.[$kind][$name] // empty' \
              ${granted-registry-lookup}
          )"

          if [[ -z "$info" ]]; then
            echo "Unknown $kind '$name'"
            exit 1
          fi

          url="$(jq -r '.url' <<<"$info")"

          mapfile -t flags < <(
            jq -r '.flags[]?' <<<"$info"
          )

          granted registry add \
            "''${flags[@]}" \
            -n "$name" \
            -p "$kind/$name" \
            -u "$url"
        '';

        completion = name: ''
          #compdef ${name}
          local lookup="${granted-registry-lookup}"

          _arguments \
            '1:kind:->kind' \
            '2:name:->name'

          case $state in
            kind)
              _values kind $(jq -r 'keys[]' "$lookup")
              ;;

            name)
              _values name $(
                jq -r --arg kind "''${words[2]}" '.[$kind] | keys[]?' "$lookup"
              )
              ;;
          esac
        '';
      })
      {
        # home.packages = [aws-add-credentials];
        home.activation.granted = lib.hm.dag.entryAfter ["writeBoundary"] ''
          install -Dm600 ${granted-config} "$HOME/.config/granted/config"
        '';
      }
    ]);
  };
}
