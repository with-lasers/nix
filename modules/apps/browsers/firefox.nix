{inputs, ...}: {
  flake.homeModules.firefox = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: let
    firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    profilePath = "${config.programs.firefox.configPath}/${config.home.username}";
  in {
    home.file.".mozilla/native-messaging-hosts".enable = false;
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "ff";
        runtimeInputs = [firefox];
        text = ''
          ${lib.getExe pkgs.firefox} -P ${config.home.username} "$@"
        '';
      })
    ];

    home.activation.patchFirefoxShortcuts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      FILE="${profilePath}/extension-settings.json"

      if [ -f "$FILE" ]; then
        tmp="$(mktemp)"
        ${pkgs.jq}/bin/jq '
          .commands["1"].precedenceList = [{
            id: "userchrome-toggle-extended@n2ezr.ru",
            installDate: 1000,
            value: { shortcut: "Ctrl+E" },
            enabled: true
          }]
        ' "$FILE" > "$tmp" && mv "$tmp" "$FILE"
      fi
    '';

    programs.firefox = let
      inherit (inputs.self) firefox;
    in {
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

      profiles.${config.home.username} = lib.mkMerge [
        (firefox.defaultSettings)
        (firefox.telemetry)
        (firefox.defaultExtensions firefox-addons)
        (firefox.shyfox firefox-addons)
        {
          id = 0;
          name = config.home.username;
          isDefault = true;
        }
      ];

      profiles.${username} = lib.mkMerge [
        (firefox.gamingExtensions firefox-addons)
      ];
    };

    home.sessionVariables = {
      # TODO: check if I still need this flag
      MOZ_ENABLE_WAYLAND = 1;

      # Non-nix firefox crashes without this because profiles.ini is read-only
      MOZ_LEGACY_PROFILES = 1;
    };
  };
}
