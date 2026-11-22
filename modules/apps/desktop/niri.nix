{...}: {
  flake.nixosModules.desktop = {...}: {
    programs.niri.enable = true;
  };

  flake.homeModules.niri = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Copied from https://wiki.nixos.org/wiki/Niri
    config = lib.mkMerge [
      {
        # niri never activates graphical-session.target; anchor wayland units
        # on the session unit it does start.
        wayland.systemd.target = "niri.service";

        home.packages = with pkgs; [
          swaybg
          xwayland-satellite
        ];
      }

      (lib.mkIf (!config.programs.noctalia.enable) {
        programs.swaylock.enable = true;
        programs.waybar.enable = true;
        services.mako.enable = true;
        services.swayidle.enable = true;
        services.polkit-gnome.enable = true;
      })
    ];
  };
}
