{
  flake.homeModules.git = {pkgs, ...}: {
    config = {
      home.packages = with pkgs; [
        hub
      ];

      programs.git.settings = {
        url."git@github.com:".insteadOf = [
          "git://github.com/"
          "http://github.com/"
          "https://github.com/"
        ];
      };
    };
  };
}
