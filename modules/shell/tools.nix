{
  flake.homeModules.base = {
    config,
    namespace,
    lib,
    pkgs,
    ...
  }: {
    config = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableBashIntegration = config.programs.bash.enable;
        enableZshIntegration = config.programs.zsh.enable;
        config = {
          whitelist.prefix = lib.mkDefault [
            (builtins.toPath "/persist/${config.home.homeDirectory}") # YOLO
          ];
        };
      };

      programs.eza = {
        enable = true;

        colors = "always";
        git = config.programs.git.enable;
        icons = "always";
      };

      programs.television = {
        enable = true;
        enableZshIntegration = config.programs.zsh.enable;
        settings = {
          tick_rate = 50;
          ui.use_nerd_font_icons = true;
          keybindings = {
            esc = "quit";
            ctrl-c = "quit";
          };
        };
      };

      ${namespace}.shell.aliases = lib.mkMerge [
        (lib.mkIf config.programs.eza.enable {
          ls = "eza --icons";
          l = "eza --icons -lahg";
        })
        {
          la = "ls -a";
          ll = "ls -l";
          lla = "ls -la";
          lt = "ls --tree";
        }
        {
          grep = "grep --color=auto";
          egrep = "grep -E --color=auto";
          fgrep = "grep -F --color=auto";
        }
        {
          ip = "ip --color";
        }
        {
          # Windows
          cls = "clear";
          dir = "ls";
          where = "which";
        }
        {
          sudo = "sudo ";

          cat = "bat --plain";
          v = "sudo nvim";
        }
        (lib.mkIf config.programs.vscode.enable {
          c = lib.getExe config.programs.vscode.package;
          code = lib.getExe config.programs.vscode.package;
        })
        (lib.mkIf config.programs.television.enable {
          env = "tv env";
          h = ''
            history 0 | tv | awk '{$1="";print $0}'
          '';
          hh = ''
            eval "$(history 0 | tv | awk '{$1="";print $0}')"
          '';
        })
      ];

      home.packages = with pkgs; [
        fd
        sd
        gawk
        ripgrep

        jq
        yq-go

        bat
        glow

        # rargs

        neovim
        ranger

        curl
        wget
        httpie

        btop

        fastfetch
      ];
    };
  };
}
