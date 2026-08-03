{lib, ...}: {
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

  flake.homeModules.git = {pkgs, ...}: {
    config = {
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
