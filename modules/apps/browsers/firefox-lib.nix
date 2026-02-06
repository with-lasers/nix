{lib, ...}: {
  flake.firefox = {
    containerise = let
      createContainer = containers: host: containerName:
        lib.nameValuePair "map=${host}" {
          inherit host;
          inherit containerName;
          cookieStoreId = "firefox-container-${builtins.toString containers.${containerName}.id}";
          enabled = true;
        };
    in {
      inherit createContainer;

      urls = f: hosts: (builtins.listToAttrs (map (host: f host) hosts));
      prefixed = f: hosts: (builtins.listToAttrs (map (host: f "${host}.*") hosts));
      suffixed = f: hosts: (builtins.listToAttrs (map (host: f "*.${host}") hosts));
    };

    defaultExtensions = firefox-addons: {
      extensions.force = true;
      extensions.packages = with firefox-addons; [
        # apps
        bitwarden
        raindropio

        # containers
        containerise
        granted
        multi-account-containers

        # customization
        violentmonkey
        sidebery
        darkreader

        # security
        sponsorblock
        ublock-origin
      ];

      settings = {
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;
      };
    };

    defaultSettings = {
      settings = {
        # Disable about:config warning
        "browser.aboutConfig.showWarning" = false;

        "browser.startup.homepage" = "about:home";
        "browser.disableResetPrompt" = true;
        "browser.sessionstore.resume_session_once" = true;
        "browser.sessionstore.resuming_after_os_restart" = true;

        "dom.security.https_only_mode" = true;

        # reopen session
        "browser.startup.page" = 3;

        # Disable autoplay
        "media.autoplay.default" = 5;

        # Prefer dark theme
        # 0: Dark, 1: Light, 2: Auto
        "layout.css.prefers-color-scheme.content-override" = 0;
      };
    };

    gamingExtensions = firefox-addons: {
      extensions.packages = with firefox-addons; [
        augmented-steam
      ];
    };

    shyfox = firefox-addons: {
      extensions.packages = with firefox-addons; [
        sidebery
        adaptive-tab-bar-colour
        userchrome-toggle-extended
      ];

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "sidebar.revamp" = false;
        "svg.context-properties.content.enabled" = true;
        "layout.css.has-selector.enabled" = true;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "browser.urlbar.trimURLs" = true;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
        "widget.gtk.ignore-bogus-leave-notify" = 1;
        "shyfox.enable.ext.mono.toolbar.icons" = true;
        "shyfox.enable.ext.mono.context.icons" = true;
        "shyfox.enable.context.menu.icons" = true;
        "shyfox.force.native.controls" = true;
      };
    };
  };
}
