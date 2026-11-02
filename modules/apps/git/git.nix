{lib, ...}: let
  options = {
    forges = lib.mkOption {
      description = "Git forges and the organizations hosted on them.";
      default = {};
      type = lib.types.attrsOf (lib.types.submodule {
        options.orgs = lib.mkOption {
          description = "Organizations on the forge.";
          default = [];
          type = lib.types.listOf lib.types.str;
        };
      });
    };

    profiles = lib.mkOption {
      description = ''
        Git configurations rendered under `~/.config/git/profile.d/<profile>`.
      '';
      default = {};
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          config = lib.mkOption {
            description = "Git configuration rendered into the profile's .gitconfig file.";
            type = lib.types.str;
          };

          ignore = lib.mkOption {
            description = "Git ignore patterns.";
            type = lib.types.str;
          };
        };
      });
    };
  };

  mapProfileToFile = name: profile: {
    "git/profile.d/${name}/.gitconfig".text = profile.config;
    "git/profile.d/${name}/ignore".text = profile.ignore;
  };
in {
  flake.lib.git = {
    mergeConfig = parts: builtins.concatStringsSep "\n" (map lib.generators.toGitINI parts);

    includeDirs = {
      path ? "",
      paths ? [
        "gitdir:/tmp/${path}/"
        "gitdir:/home/${path}/"
        "gitdir:~/prj/${path}/"
      ],
    }:
      map (s: "includeIf.${s}") paths;

    insteadOf = url: path: [
      "git@${url}:${path}/"
      "git://${url}/${path}/"
      "http://${url}/${path}/"
      "https://${url}/${path}/"
    ];

    renderIgnore = ignore:
      lib.concatStringsSep "\n\n" (
        lib.mapAttrsToList (title: patterns: ''
          # ${title}
          ${lib.concatStringsSep "\n" patterns}
        '')
        ignore
      );
  };

  flake.homeModules.git = {
    config,
    pkgs,
    namespace,
    ...
  }: {
    options.${namespace}.git = options;
    config = {
      xdg.configFile = lib.concatMapAttrs mapProfileToFile config.${namespace}.git.profiles;
      programs.delta.enableGitIntegration = true;
      programs.git = {
        enable = true;
        package = pkgs.gitMinimal;

        includes = [
          {path = "~/.config/git/.gitconfig";}
        ];

        lfs.enable = true;

        settings = {
          color.ui = "auto";

          advice.skippedCherryPicks = false;

          apply.whitespace = "fix";

          branch.autosetuprebase = "always";

          help.autocorrect = "10";

          init.defaultBranch = "main";
          core.excludesFile = "~/.config/git/ignore";
          core.quotePath = "off";
          core.editor = "nvim";

          pull.ff = "only";
          push.default = "current";
          push.autoSetupRemote = "true";
          rebase.autosquash = "true";
          rerere.enabled = "true";
        };
      };
    };
  };
}
