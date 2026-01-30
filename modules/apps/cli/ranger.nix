{
  flake.homeModules.cli = {namespace, ...}: {
    config = {
      ${namespace}.shell.aliases = {
        r = "ranger";
      };

      home.file = {
        ".config/ranger/rc.conf".text = ''
          set show_hidden true
          set vcs_aware false
          set vcs_backend_git enabled

          map <DELETE> delete
          map cd console cd%space
        '';
      };
    };
  };

  flake.nixosModules.cli = {pkgs, ...}: {
    config.environment.systemPackages = with pkgs; [
      ranger
    ];
  };
}
