{...}: {
  flake.homeModules.development = {
    lib,
    pkgs,
    ...
  }: {
    config = let
      wrapper = with pkgs;
        writeShellApplication {
          name = "steampipe";
          runtimeInputs = [steampipe];
          text = ''
            # this is the --install-dir flag
            export STEAMPIPE_INSTALL_DIR="$XDG_CONFIG_HOME/steampipe"
            exec ${lib.getExe steampipe} "$@"
          '';
        };
    in {
      home.packages = [
        wrapper
      ];

      systemd.user.services.steampipe = {
        Unit = {
          Description = "steampipe service";
          After = ["network.target"];
        };
        Service = {
          ExecStart = "${lib.getExe wrapper} service start --foreground";
          Restart = "on-failure";
        };
        Install.WantedBy = ["default.target"];
      };

      # TODO: configure port as an option
      xdg.configFile."steampipe/config/default.spc".text = ''
        options "database" {
          port               = 9193
          listen             = "network"
          start_timeout      = 30
          cache              = true
          cache_max_ttl      = ${builtins.toString (15 * 60)}
          cache_max_size_mb  = 1024
        }

        options "general" {
          update_check  = false
          telemetry     = "none"
          log_level     = "info" # trace, debug, info, warn, error
          memory_max_mb = "1024"
        }
      '';
    };
  };
}
