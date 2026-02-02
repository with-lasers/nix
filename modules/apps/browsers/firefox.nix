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
        containerise
        multi-account-containers
        sidebery
        ublock-origin
        sponsorblock
        violentmonkey

        darkreader
        raindropio

        granted # aws containers
      ];
    };
    settings = {
      "extensions.autoDisableScopes" = 0;
      "extensions.enabledScopes" = 15;
    };
  in {
    home.file.".mozilla/native-messaging-hosts".enable = false;

    programs.firefox = {
      enable = true;

      # Depends on the firefox 147+
      # check https://github.com/nix-community/home-manager/issues/8200
      configPath = "${config.xdg.configHome}/mozilla/firefox";

      # check https://mozilla.github.io/policy-templates
      policies = {
        # Update via nix
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;

        # Disable "save password" prompt (signon.rememberSignons)
        # (using bitwarden)
        PasswordManagerEnabled = false;
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
        inherit settings;
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
