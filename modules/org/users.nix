{
  flake.nixosModules.organization = {
    config,
    lib,
    namespace,
    username,
    pkgs,
    ...
  }: let
    profiles = config.${namespace}.profiles;
    perUser = f: lib.mapAttrs f profiles;

    createGroup = name: profile: {
      inherit name;
      gid = profile.user.id;
      members = [name username];
    };

    createUser = name: profile: {
      inherit name;
      group = name;

      uid = profile.user.id;

      isNormalUser = true;
      description = builtins.concatStringsSep "," [
        (builtins.replaceStrings ["@"] [","] profile.user.email)
        ""
        ""
        "umask=002"
      ];
    };

    configureUser = name: _profile: {
      home = let
        hm = config.home-manager.users.${name};
      in {
        username = name;
        homeDirectory = "/home/${hm.home.username}";
      };
    };
  in {
    config = {
      users.users = perUser createUser;
      users.groups = perUser createGroup;

      home-manager.users = perUser configureUser;

      security.pam.services.login.text = lib.mkDefault "session optional ${pkgs.pam}/lib/security/pam_umask.so\n";

      services.displayManager.sddm.settings = lib.mkIf config.services.displayManager.sddm.enable {
        Users.HideUsers = builtins.concatStringsSep "," (builtins.attrNames profiles);
      };
    };
  };
}
