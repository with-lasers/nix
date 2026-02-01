{
  flake.homeModules.development = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: {
    config = {
      ${namespace}.shell.aliases = {
        d = "docker";

        # https://github.com/docker-archive/compose-cli/issues/1404
        # use docker compose (v2, go) instead of docker-compose (v1, python)
        dc = "docker compose";
        dcu = "docker compose up -d";
        lzd = "lazydocker";
      };

      home.packages = with pkgs; let
        entrypoints = map (cmd:
          writeShellApplication {
            name = "${cmd}-it";
            text = ''docker run --rm -it --entrypoint ${cmd} "$@"'';
          }) ["bash" "ash" "sh" "node"];

        latestTags = map (type: (writeShellApplication {
          name = "latest-${type}-tag";
          text = ''latest-tag "$1" "${type}"'';
        })) ["snapshot" "release"];
      in
        lib.concatLists [
          latestTags
          entrypoints
          [
            (writeShellApplication {
              name = "latest-tag";
              runtimeInputs = [regctl ripgrep];
              text = ''
                registry="''${IMAGE_REGISTRY:-docker.io}"
                regctl tag ls "$registry/$1" | rg "$2-\\d{14}\$" | sort -V | tail -n1
              '';
            })
          ]
        ];
    };
  };
}
