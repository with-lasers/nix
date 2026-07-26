{
  flake.homeModules.base = {lib, ...}: {
    config = {
      programs.zsh.initContent = lib.mkOrder 550 ''
        fpath+=($HOME/.config/zsh/completions)
      '';
    };
  };
}
