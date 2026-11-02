{inputs, ...}: {
  config.flake-file = {
    formatter = pkgs: pkgs.alejandra;

    inputs = {
      treefmt-nix.url = "github:numtide/treefmt-nix";
      treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  config.perSystem = {config, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";

      settings.formatter = {
        write-flake = {
          command = config.packages.write-flake;
          includes = ["*.nix"];
          priority = 0;
        };
      };

      programs = {
        deadnix = {
          enable = true;
          priority = 1;
        };

        alejandra = {
          enable = true;
          priority = 2;
        };
      };
    };
  };

  imports = [inputs.treefmt-nix.flakeModule];
}
