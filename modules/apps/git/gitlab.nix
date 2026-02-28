{
  flake.homeModules.git = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = {
      home.file.".config/lab/lab.toml".text = ''
        [mr_create]
          draft = false
      '';

      home.packages = with pkgs; [
        (writeShellApplication {
          name = "lab";
          runtimeInputs = [lab];
          text = ''
            # A wrapper to use multiple "profiles"

            LAB_CORE_HOST="https://gitlab.com" \
            LAB_CORE_TOKEN=$GITLAB_TOKEN \
            ${pkgs.lab}/bin/lab "$@"
          '';
        })

        (writeShellApplication {
          name = "gitlab";
          runtimeInputs = [httpie];
          text = ''
            # A wrapper to make API calls to the GitLab API

            https "$@" "Authorization:Bearer $GITLAB_TOKEN"
          '';
        })
      ];

      programs.git.settings = {
        url."git@gitlab.com:".insteadOf = [
          "http://gitlab.com/"
          "https://gitlab.com/"
          "git://gitlab.com/"
        ];
      };

      programs.zsh = {
        zsh-abbr = {
          abbreviations = let
            c = config.home.sessionVariables.ABBR_LINE_CURSOR_MARKER;
          in {
            "gl mr" = "git push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.target=${c} ${c}";
          };
        };
      };
    };
  };
}
