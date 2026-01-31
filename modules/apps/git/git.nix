{
  flake.homeModules.git = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: {
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
