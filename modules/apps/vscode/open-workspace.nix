{
  flake.homeModules.vscode = {
    config,
    lib,
    pkgs,
    ...
  }: let
    channel = "code-workspaces";
  in {
    config = lib.mkIf config.programs.vscode.enable {
      programs.television.channels.${channel} = {
        metadata.name = "code-workspaces";
        metadata.description = "list vscode workspaces";
        metadata.requirements = ["tr" "xargs" "fd" "bat"];
        source.command = "echo $PROJECT_ROOTS | tr ':' '\\n' | xargs fd .code-workspace -t f {}";
        preview.command = "bat -n -l json --color=always {}";
      };

      programs.zsh.zsh-abbr.abbreviations = {
        "cw" = "tv ${channel}";
      };

      home.packages = with pkgs; [
        # Open code Workspaces
        (writeShellApplication {
          name = "open-workspace";
          runtimeInputs = [
            fd
            config.programs.rofi.package
            config.programs.television.package
            config.programs.vscode.package
          ];
          text = ''
            TITLE="Select workspace: "
            IFS=':' read -r -a ROOTS <<< "$PROJECT_ROOTS"
            if tty -s; then
              WORKSPACE=$(${lib.getExe config.programs.television.package} ${channel} --input-header "$TITLE")
            else
              WORKSPACE=$(fd .code-workspace "''${ROOTS[@]}" | ${lib.getExe config.programs.rofi.package} -dmenu -p "$TITLE")
            fi

            if [[ -f "$WORKSPACE" ]]; then
              ${lib.getExe config.programs.vscode.package} "$WORKSPACE"
            fi
          '';
        })
      ];
    };
  };
}
