{...}: {
  flake.lib.steampipe = {
    aws = {
      connection = {
        name,
        profile,
        regions,
      }: ''
        connection "${name}" {
          plugin  = "aws"
          profile = "${profile}"
          regions = ${builtins.toJSON regions}
        }
      '';

      aggregation = {
        name,
        connections,
      }: ''
        connection "${name}" {
          plugin      = "aws"
          type        = "aggregator"
          connections = ${builtins.toJSON connections}
        }
      '';
    };

    k8s = {
      connection = {
        name,
        context,
        configPath ? "~/.kube/config",
        sourceTypes ? ["deployed"],
        customResourceTables ? ["*"],
      }: ''
        connection "${name}" {
          plugin                 = "kubernetes"
          config_path            = "${configPath}"
          config_context         = "${context}"
          source_types           = ${builtins.toJSON sourceTypes}
          custom_resource_tables = ${builtins.toJSON customResourceTables}
        }
      '';

      aggregation = {
        name,
        connections,
      }: ''
        connection "${name}" {
          plugin      = "kubernetes"
          type        = "aggregator"
          connections = ${builtins.toJSON connections}
          custom_resource_tables = ["*"]
        }
      '';
    };
  };

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
