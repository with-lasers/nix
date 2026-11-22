{...}: {
  flake.nixosModules.desktop = {
    config,
    lib,
    namespace,
    ...
  }: {
    options.${namespace}.noctalia = {
      enable = lib.mkEnableOption "noctalia";
    };

    config = lib.mkIf config.${namespace}.noctalia.enable {
      # Home Manager owns the noctalia unit; the NixOS module only pulls in
      # the package and the freedesktop sound theme.
      programs.noctalia = {
        enable = true;
        systemd.enable = false;
      };
    };
  };

  flake.homeModules.desktop = {
    config,
    lib,
    namespace,
    ...
  }: {
    options.${namespace}.noctalia = {
      enable = lib.mkEnableOption "noctalia";
    };

    config = lib.mkIf config.${namespace}.noctalia.enable {
      # noctalia rewrites config.toml when settings change from its GUI, so
      # let activation replace whatever is there with the declarative version.
      xdg.configFile."noctalia/config.toml".force = true;

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings = {
          backdrop = {
            blur_intensity = 0;
            enabled = true;
            tint_intensity = 0.21;
          };

          calendar = {};

          control_center.calendar.show_events_card = false;

          dock.background_opacity = 0.8;

          idle = {
            behavior_order = ["screen-off" "lock"];
            behavior = {
              "screen-off" = {
                action = "screen_off";
                timeout = 300;
              };
              lock = {
                action = "lock";
                timeout = 600;
              };
            };
          };

          notification.background_opacity = 0.8;
          osd.background_opacity = 0.8;

          # Noctalia's own agent serves polkit in the niri session.
          shell = {
            polkit_agent = true;
            corner_radius_scale = 0;
            font_family = "NotoSans Nerd Font";
            launcher.app_grid = true;
          };

          wallpaper = {
            enabled = true;
            fill_mode = "span";
            transition = ["crt"];
          };

          widget.sysmon.visualization = "none";
        };
      };
    };
  };
}
