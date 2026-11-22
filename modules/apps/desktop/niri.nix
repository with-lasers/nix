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
