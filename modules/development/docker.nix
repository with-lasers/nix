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
    };
  };
}
