{...}: {
  flake.nixosModules.desktop = {
    config,
    pkgs,
    ...
  }: {
    programs.niri.enable = true;
  };

  flake.homeModules.niri = {pkgs, ...}: {
    # Copied from https://wiki.nixos.org/wiki/Niri
    config = {
      programs.swaylock.enable = true;
      programs.waybar.enable = true;
      services.mako.enable = true;
      services.swayidle.enable = true;
      services.polkit-gnome.enable = true;
      home.packages = with pkgs; [
        swaybg
        xwayland-satellite
      ];
    };
  };
}
