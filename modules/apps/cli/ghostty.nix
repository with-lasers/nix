{
  flake.homeModules.desktop = {config, ...}: {
    config.programs.ghostty = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      installBatSyntax = true;

      settings = {
        font-family = "FiraCode Nerd Font Mono";

        # set by stylix
        # background-opacity = "0.75";
        window-decoration = "none";
        window-padding-x = 12;
        window-padding-y = 12;

        # TODO: check if this work with tiling WMs?
        quick-terminal-position = "center";

        # Escape hatch for testing
        config-file = "?~/.config/ghostty/extra";
      };
    };
  };
}
