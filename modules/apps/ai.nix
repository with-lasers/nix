{lib, inputs, ...}: {
  perSystem = {
    pkgs,
    ...
  }: {
    devShells.ai = pkgs.mkShell {
      packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        crush
        opencode
        pi
      ];
    };
  };

  flake.nixosModules.ai = {
    pkgs,
    username,
    ...
  }: let
    # TODO: make module options
    group = "models";
    port = 10666;
    models-dir = "/srv/llm";
  in {
    config = {
      hardware.graphics.enable = true;

      users.groups.${group} = {
        members = [username];
      };

      systemd.tmpfiles.rules = [
        "d ${models-dir} 2770 root ${group} - -"
      ];

      environment.systemPackages = with pkgs; [
        (pkgs.writeShellApplication {
          name = "models-reload";
          runtimeInputs = [pkgs.httpie];
          text = ''
            http localhost:${builtins.toString port}/models reload==1
          '';
        })
      ];

      # Overrides the <services.llama-cpp> options
      systemd.services.llama-cpp.serviceConfig = {
        SupplementaryGroups = [group];
      };

      # TODO: remove after https://github.com/NixOS/nixpkgs/pull/531127
      networking.firewall.allowedTCPPorts = [port];

      # Data is stored in /var/{cache,lib}/llama-cpp
      services.llama-cpp = {
        enable = true;
        package = pkgs.llama-cpp.override {
          vulkanSupport = true;
        };

        # TODO: use a reverse proxy and remove 0.0.0.0 listening
        # openFirewall = true;

        # Docs: https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
        settings = {
          inherit port;
          inherit models-dir;

          # TODO: use a reverse proxy and remove 0.0.0.0 listening
          host = "0.0.0.0";
          models-max = 1; # Force swapping models
          cache-ram = "-1"; # (default: 8192 MB)
          ctx-size = "0"; # Context size (flags: -c)
          gpu-layers = "all"; # fit everything in VRAM (flags: -ngl / --n-gpu-layers)
        };
      };
    };
  };
}
