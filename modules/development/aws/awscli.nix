{
  flake.homeModules.development = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = {
      programs.granted = {
        enable = lib.mkDefault true;
        enableZshIntegration = config.programs.zsh.enable;
      };

      home.packages = with pkgs; [
        awscli2
      ];
    };
  };
}
