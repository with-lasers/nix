{
  flake.homeModules.desktop = {config, ...}: {
    config.programs.wezterm = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
