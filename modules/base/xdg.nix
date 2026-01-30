{
  flake.homeModules.base = {
    config,
    pkgs,
    namespace,
    ...
  }: {
    config.xdg = {
      enable = true;

      userDirs = {
        enable = true;

        # Lowercase the dirs
        desktop = "${config.home.homeDirectory}/desktop";
        documents = "${config.home.homeDirectory}/documents";
        publicShare = "${config.home.homeDirectory}/public";

        # Media (you should override this with lib.mkForce)
        music = "/storage/music";
        pictures = "/storage/pictures";
        videos = "/storage/videos";
        templates = "/storage/templates";
        download = "/storage/inbox";
      };
    };
  };
}
