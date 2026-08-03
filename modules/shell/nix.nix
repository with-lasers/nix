{
  flake.homeModules.base = {
    config,
    pkgs,
    namespace,
    ...
  }: {
    config = {
      ${namespace}.shell.aliases = {
        hms = "nh home switch $NIXOS_REPO";
        nup = "nh os switch $NIXOS_REPO";
        nfu = "nix-flake-update";
      };

      home.homeDirectory = "/home/${config.home.username}";
      home.packages = with pkgs; [
        nh
        devenv
        (writeShellApplication {
          name = "nix-flake-update";
          runtimeInputs = [gh];
          text = ''
            NIX_CONFIG="access-tokens = github.com=$(gh auth token)" nix flake update
          '';
        })
      ];
    };
  };
}
