{
  flake.homeModules.git = {
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
    };
  };
}
