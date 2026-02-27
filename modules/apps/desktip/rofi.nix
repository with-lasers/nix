{lib, ...}: {
  flake.homeModules.desktop = {
    pkgs,
    config,
    ...
  }: let
    # TODO: use rasi mkLiteral?
    mkTheme = accent: ''
      /**
       * User: ${config.home.username}
       */
      * {
          /* Colors */
          dark: #00000080;
          light: #ffffff80;
          accent: ${accent};

          background: @dark;
          foreground: @accent;
          alt-foreground: @light;

          normal-foreground:           @foreground;
          normal-background:           @background;
          alternate-normal-foreground: @foreground;
          alternate-normal-background: ${accent}10;

          selected-normal-foreground: @alt-foreground;
          selected-normal-background: ${accent}30;

          urgent-background:           @background;
          urgent-foreground:           #c34b4eff;
          selected-urgent-background:  #c34b4e30;
          selected-urgent-foreground:  @light;
          alternate-urgent-background: @background;
          alternate-urgent-foreground: @urgent-foreground;

          active-background:           @background;
          active-foreground:           #4bc38cff;
          selected-active-background:  #4bc38c30;
          selected-active-foreground:  @light;
          alternate-active-background: @background;
          alternate-active-foreground: @active-foreground;

          separatorcolor:              @foreground;
          background-color:            @background;
      }
      window {
          background-color: @background;
          border:           1;
          padding:          5;
      }
      mainbox {
          border:  0;
          padding: 0;
      }
      message {
          border:       1px dash 0px 0px;
          border-color: @separatorcolor;
          padding:      1px ;
      }
      textbox {
          text-color: @foreground;
      }
      listview {
          fixed-height: 0;
          border:       2px dash 0px 0px;
          border-color: @separatorcolor;
          spacing:      2px;
          scrollbar:    true;
          padding:      2px 0px 0px;
      }
      element {
          border:  0;
          padding: 4px 0;
      }
      element-text {
          background-color: inherit;
          text-color:       inherit;
      }
      element.normal.normal {
          background-color: @normal-background;
          text-color:       @normal-foreground;
      }
      element.normal.urgent {
          background-color: @urgent-background;
          text-color:       @urgent-foreground;
      }
      element.normal.active {
          background-color: @active-background;
          text-color:       @active-foreground;
      }
      element.selected.normal {
          background-color: @selected-normal-background;
          text-color:       @selected-normal-foreground;
      }
      element.selected.urgent {
          background-color: @selected-urgent-background;
          text-color:       @selected-urgent-foreground;
      }
      element.selected.active {
          background-color: @selected-active-background;
          text-color:       @selected-active-foreground;
      }
      element.alternate.normal {
          background-color: @alternate-normal-background;
          text-color:       @alternate-normal-foreground;
      }
      element.alternate.urgent {
          background-color: @alternate-urgent-background;
          text-color:       @alternate-urgent-foreground;
      }
      element.alternate.active {
          background-color: @alternate-active-background;
          text-color:       @alternate-active-foreground;
      }
      scrollbar {
          width:        0px;
          border:       0;
          handle-width: 0px;
          padding:      0;
      }
      mode-switcher {
          border:       2px dash 0px 0px;
          border-color: @separatorcolor;
      }
      button.selected {
          background-color: @selected-normal-background;
          text-color:       @selected-normal-foreground;
      }
      inputbar {
          spacing:    0;
          text-color: @normal-foreground;
          padding:    16px;
      }
      case-indicator {
          spacing:    0;
          text-color: @normal-foreground;
      }
      entry {
          spacing:    0;
          text-color: @normal-foreground;
      }
      prompt {
          spacing:    0;
          text-color: @normal-foreground;
      }
      inputbar {
          children:   [ textbox-prompt-colon, entry, case-indicator ];
      }
      textbox-prompt-colon {
          expand:     false;
          str:        "λ";
          margin:     0px 1em 0em 0em;
          text-color: @normal-foreground;
      }
    '';
  in {
    config = {
      stylix.targets.rofi.enable = false;

      # Test colors
      xdg.dataFile."rofi/themes/λ-darkgray.rasi".text = mkTheme "#A9A9A9";
      xdg.dataFile."rofi/themes/λ-red.rasi".text = mkTheme "#ff0000";
      xdg.dataFile."rofi/themes/λ-orange.rasi".text = mkTheme "#ff7700";
      xdg.dataFile."rofi/themes/λ-yellow.rasi".text = mkTheme "#ffee00";
      xdg.dataFile."rofi/themes/λ-teal.rasi".text = mkTheme "#067080";
      xdg.dataFile."rofi/themes/λ-blue.rasi".text = mkTheme "#008Aff";
      xdg.dataFile."rofi/themes/λ-purple.rasi".text = mkTheme "#7229E6";
      xdg.dataFile."rofi/themes/λ-magenta.rasi".text = mkTheme "#D1008B";
      xdg.dataFile."rofi/themes/λ-hot-pink.rasi".text = mkTheme "#FD38BA";

      xdg.dataFile."rofi/themes/λ-stylix.rasi".text = mkTheme config.lib.stylix.colors.withHashtag.base03;

      programs.rofi = {
        enable = true;

        location = "center";
        cycle = true;

        theme = lib.mkDefault "λ-stylix";
      };

      programs.plasma.hotkeys.commands = {
        rofi = {
          command = "${lib.getExe config.programs.rofi.package} -show combi -combi-modes window,run,ssh,filebrowser";
          comment = "Launch rofi";
          key = "Meta+Space";
        };
        rofi-run = {
          command = "${lib.getExe config.programs.rofi.package} -show run";
          comment = "Run rofi";
          key = "Meta+R";
        };
      };
    };
  };
}
