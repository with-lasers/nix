{
  # FIXME(hm): can't output the control chars, like \u001b, so I just link them
  flake.homeModules.vscode = {
    config,
    inputs,
    lib,
    ...
  }: {
    config = {
      home.file = lib.mkMerge [
        {
          ".config/Code/User/keybindings.json".source = ./keybindings.json;
        }
        (
          lib.mapAttrs' (profile: _: {
            name = ".config/Code/User/profiles/${profile}/keybindings.json";
            value.source = ./keybindings.json;
          })
          config.programs.vscode.profiles
        )
      ];
    };
  };
}
