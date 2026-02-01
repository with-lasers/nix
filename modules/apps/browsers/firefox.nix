{inputs, ...}: {
  flake.homeModules.firefox = {
    config,
    pkgs,
    ...
  }: let
    firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    extensions = {
      force = true;
      packages = with firefox-addons; [
        bitwarden
        multi-account-containers
        sidebery
        ublock-origin
        violentmonkey

        granted # aws containers
      ];
    };
  in {
    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        ExtensionSettings = {
          "ebay@search.mozilla.org".installation_mode = "blocked";
          "amazondotcom@search.mozilla.org".installation_mode = "blocked";
          "bing@search.mozilla.org".installation_mode = "blocked";
          "ddg@search.mozilla.org".installation_mode = "blocked";
          "wikipedia@search.mozilla.org".installation_mode = "blocked";
        };
      };

      profiles.${config.home.username} = {
        inherit extensions;
        id = 0;
        name = config.home.username;
        isDefault = true;
      };
    };

    home.sessionVariables = {
      # TODO: check if I still need this flag
      MOZ_ENABLE_WAYLAND = 1;

      # Non-nix firefox crashes without this because profiles.ini is read-only
      MOZ_LEGACY_PROFILES = 1;
    };
  };
}
