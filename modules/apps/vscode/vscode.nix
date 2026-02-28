{
  inputs,
  ...
}: {
  flake.nixosModules.vscode = {
    ...
  }: {
    config.nixpkgs.overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  flake.homeModules.vscode = {
    config,
    lib,
    pkgs,
    inputs,
    namespace,
    ...
  }: let
    feat-remote = marketplace: {
      extensions = with marketplace; [
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.live-server
        ms-vscode.remote-explorer
        ms-vsliveshare.vsliveshare
      ];
    };

    feat-theming = marketplace: {
      extensions = with marketplace; [
        eliverlara.andromeda # Andromeda
        andrsdc.base16-themes # Base16 Themes
        gerane.theme-brogrammer # Brogrammer
        wesbos.theme-cobalt2 # Cobalt 2
        dracula-theme.theme-dracula # Dracula
        jdinhlife.gruvbox # Gruvbox
        pkief.material-icon-theme # Material Icons
        sdras.night-owl # Night Owl
        johnpapa.vscode-peacock # Peacock
        ahmadawais.shades-of-purple # Shades of Purple
        enkia.tokyo-night # Tokyo Night
        ms-vscode.theme-tomorrowkit # Tomorrow Night
        vscode-icons-team.vscode-icons
      ];
    };

    feat-ux = marketplace: {
      extensions = with marketplace; [
        wraith13.bracket-lens
        ms-vscode.sublime-keybindings
        naumovs.color-highlight # css colors
      ];
    };

    profile-dev = marketplace: {
      extensions = with marketplace; [
        # Git
        donjayamanne.githistory
        eamodio.gitlens

        # Docker
        docker.docker
        ms-azuretools.vscode-containers

        # Kubernetes
        ms-kubernetes-tools.vscode-kubernetes-tools
        redhat.vscode-yaml
        tilt-dev.tiltfile
      ];

      userSettings = {
        "vs-kubernetes" = {
          "vs-kubernetes.crd-code-completion" = "enabled";
        };

        "[yaml]" = {
          "editor.defaultFormatter" = "redhat.vscode-yaml";
        };

        "files.associations".".yml" = "yaml";
        "yaml.customTags" = [
          "reference" # GitLab CI
        ];
      };
    };

    profile-ops = marketplace: {
      extensions = with marketplace; [
        hashicorp.hcl
        hashicorp.terraform

        ahmadalli.vscode-nginx-conf
      ];
    };

    lang-markdown = marketplace: {
      extensions = with marketplace; [
        davidanson.vscode-markdownlint
        shd101wyy.markdown-preview-enhanced
        searking.preview-vscode
        takumii.markdowntable
        unifiedjs.vscode-mdx

        # Diagrams
        terrastruct.d2
        pomdtr.markdown-kroki

        # Task Runner
        # stateful.runme

        foam.foam-vscode # Roam-like editor
      ];

      userSettings = {
        # Obsidian
        "files.associations"."*.base" = "yaml";

        "[mdx]"."editor.defaultFormatter" = "unifiedjs.vscode-mdx";
      };
    };

    lang-nix = marketplace: {
      extensions = with marketplace; [
        bbenoist.nix
        jnoortheen.nix-ide
        kdl-org.kdl
      ];

      userSettings = {
        "files.associations"."flake.lock" = "json";
      };
    };

    lang-plaintext = marketplace: {
      extensions = with marketplace; [
        adrientoub.base64utils
        gruntfuggly.todo-tree
        janjoerke.align-by-regex
        jkjustjoshing.vscode-text-pastry
        mechatroner.rainbow-csv
        tamasfe.even-better-toml
        wscourge.togglecase

        # cSpell
        # FIXME: add a custom dict and re-enable extensions or remove it
        # streetsidesoftware.code-spell-checker
        # streetsidesoftware.code-spell-checker-portuguese-brazilian
      ];

      userSettings = {
        # My default configuration for tab / spacings
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
        "editor.useTabStops" = false;
        "editor.rulers" = [79 99 119 149];

        "editor.trimAutoWhitespace" = true;
        "files.trimTrailingWhitespace" = true;

        "files.associations".".env" = "properties";

        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;

        "[env]" = {
          "files.insertFinalNewline" = false;
        };

        "[plaintext]" = {
          "files.insertFinalNewline" = false;
        };

        "cSpell.language" = "en,pt-BR";
      };
    };

    # fullstack webdev
    lang-web = marketplace: {
      extensions = with marketplace; [
        christian-kohler.npm-intellisense
        christian-kohler.path-intellisense

        # Lint
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode

        # Test
        alexkrechik.cucumberautocomplete
        cucumberopen.cucumber-official
        hindlemail.cover
        orta.vscode-jest
        ryanluker.vscode-coverage-gutters

        astro-build.astro-vscode
        graphql.vscode-graphql
        graphql.vscode-graphql-execution
        graphql.vscode-graphql-syntax

        # Format
        adpyke.vscode-sql-formatter

        # env
        irongeek.vscode-env

        # Templates
        eseom.nunjucks-template
        samuelcolvin.jinjahtml

        # Proto buffers
        zxh404.vscode-proto3
      ];

      userSettings = {
        "[html]" = {
          "editor.defaultFormatter" = "vscode.html-language-features";
        };

        "[javascript]" = {
          "editor.defaultFormatter" = "vscode.typescript-language-features";
        };
      };
    };

    profile-ai = marketplace: {
      extensions = with marketplace; [
        github.copilot
        github.copilot-chat
      ];
    };
  in {
    config = {
      programs.vscode = {
        enable = true;
        profiles = {
          default = lib.mkMerge [
            (feat-ux pkgs.vscode-marketplace)
            (feat-theming pkgs.vscode-marketplace)
            (feat-remote pkgs.vscode-marketplace)
            (lang-plaintext pkgs.vscode-marketplace)
            (lang-markdown pkgs.vscode-marketplace)
            (lang-nix pkgs.vscode-marketplace)
            (lang-web pkgs.vscode-marketplace)
            (profile-dev pkgs.vscode-marketplace)
            (profile-ops pkgs.vscode-marketplace)
            (profile-ai pkgs.vscode-marketplace)
            {
              userSettings = {
                # Disable telemetry
                "telemetry.telemetryLevel" = "off";
                "redhat.telemetry.enabled" = false;

                # https://code.visualstudio.com/docs/editor/workspace-trust
                "security.workspace.trust.enabled" = false;

                # Can't use spaces with Makefiles
                "[makefile]" = {
                  "editor.detectIndentation" = false;
                  "editor.insertSpaces" = false;
                  "editor.useTabStops" = true;
                };
              };
            }
          ];

          braindump = lib.mkMerge [
            (feat-ux pkgs.vscode-marketplace)
            (feat-theming pkgs.vscode-marketplace)
            (lang-plaintext pkgs.vscode-marketplace)
            (lang-markdown pkgs.vscode-marketplace)
            (lang-web pkgs.vscode-marketplace)
          ];

          latex = lib.mkMerge [
            (feat-ux pkgs.vscode-marketplace)
            (feat-theming pkgs.vscode-marketplace)
            (lang-plaintext pkgs.vscode-marketplace)
            {
              extensions = with pkgs.vscode-marketplace; [
                james-yu.latex-workshop
                tecosaur.latex-utilities
                torn4dom4n.latex-support
              ];
            }
          ];

          nix = lib.mkMerge [
            (feat-ux pkgs.vscode-marketplace)
            (feat-theming pkgs.vscode-marketplace)
            (lang-plaintext pkgs.vscode-marketplace)
            (lang-nix pkgs.vscode-marketplace)
            {
              userSettings = {
                "workbench.colorTheme" = "Tokyo Night";
              };
            }
          ];
        };
      };
    };
  };
}
