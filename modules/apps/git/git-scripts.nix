{
  flake.homeModules.git = {pkgs, ...}: {
    config.home.packages = with pkgs; [
      # TODO: get the first remote by default (e.g.: sometimes the remote is named upstream)
      (writeShellApplication {
        name = "git-url";
        runtimeInputs = [
          git
          sd
        ];
        text = ''
          # Gitlab Helper to get the repo URL and click from terminal

          # shellcheck disable=SC2016
          git remote get-url "''${1-origin}" | \
            sd 'git@(?:[\w.]+\.)?((?:[\w]+.){2}):(.+)' 'https://$1/$2'
        '';
      })
      # Gitlab Helper to get the URL-encoded path
      # used to replace the group ID in API calls
      (writeShellApplication {
        name = "git-path-encoded";
        runtimeInputs = [
          gitMinimal
          sd
          python3Minimal
        ];
        text = ''
          function get-git-url {
            git remote get-url "$1"
          }

          function extract-path {
            # shellcheck disable=SC2016
            sd 'git@([\w.]+):(.+)(\.git)?$' '$2'
          }

          function encode-url {
            python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read(), safe='\n'))"
          }

          get-git-url "''${1-origin}" | extract-path | encode-url
        '';
      })
    ];
  };
}
