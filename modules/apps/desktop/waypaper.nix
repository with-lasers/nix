{...}: {
  flake.nixosModules.desktop = {
    config,
    lib,
    namespace,
    pkgs,
    username,
    ...
  }: {
    options.${namespace}.waypaper = {
      enable = lib.mkEnableOption "waypaper";

      folder = lib.mkOption {
        type = lib.types.str;
        default = "${config.home-manager.users.${username}.xdg.userDirs.pictures}/wallpapers";
        description = "Directory waypaper opens by default.";
      };
    };

    config = lib.mkIf config.${namespace}.waypaper.enable {
      environment.etc."skel/.config/waypaper/config.ini".source = (pkgs.formats.ini {}).generate "config.ini" {
        Settings = {
          backend = "awww";
          color = "#000000";
          fill = "fill";
          folder = config.${namespace}.waypaper.folder;
          language = "en";
          number_of_columns = 4;
          show_hidden = false;
          subfolders = false;
          swww_transition_angle = 0;
          swww_transition_duration = 1;
          swww_transition_fps = 60;
          swww_transition_step = 90;
          swww_transition_type = "any";
        };
      };
    };
  };

  flake.homeModules.desktop = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: {
    options.${namespace}.waypaper = {
      enable = lib.mkEnableOption "waypaper";
    };

    config = lib.mkIf config.${namespace}.waypaper.enable {
      home.packages = [
        pkgs.awww
        pkgs.waypaper
      ];

      systemd.user.services.awww-daemon = {
        Unit = {
          Description = "awww wallpaper daemon";
          PartOf = [config.wayland.systemd.target];
          After = [config.wayland.systemd.target];
        };
        Service = {
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
          Restart = "on-failure";
        };
        Install.WantedBy = [config.wayland.systemd.target];
      };

      systemd.user.services.waypaper-restore = {
        Unit = {
          Description = "Restore the last waypaper wallpaper";
          PartOf = [config.wayland.systemd.target];
          After = ["awww-daemon.service" config.wayland.systemd.target];
          Requires = ["awww-daemon.service"];
        };
        Service = {
          Type = "oneshot";
          # awww-daemon has no sd_notify, so wait until it answers before
          # restoring, otherwise the race loses the first wallpaper.
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "waypaper-restore";
            runtimeInputs = [pkgs.awww pkgs.coreutils pkgs.waypaper];
            text = ''
              until awww query >/dev/null 2>&1; do
                sleep 0.5
              done
              exec waypaper --restore
            '';
          });
        };
        Install.WantedBy = [config.wayland.systemd.target];
      };

      # waypaper rewrites its config on every pick, so it cannot be a read-only
      # store symlink: seed it from the /etc/skel template once and let
      # waypaper own the file afterwards.
      home.activation.waypaperConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        CONFIG="${config.xdg.configHome}/waypaper/config.ini"
        SKEL="/etc/skel/.config/waypaper/config.ini"
        if [ -f "$CONFIG" ]; then
          # Older activations copied the store template, leaving it read-only.
          if [ ! -w "$CONFIG" ] && [ ! -L "$CONFIG" ]; then
            run chmod u+w "$CONFIG"
          fi
        elif [ -f "$SKEL" ]; then
          run mkdir -p "$(dirname "$CONFIG")"
          run install -m 0600 "$SKEL" "$CONFIG"
        fi
      '';
    };
  };
}
