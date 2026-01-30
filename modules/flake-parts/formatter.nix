{lib, ...}: {
  perSystem = {pkgs, ...}: {
    formatter = pkgs.writeShellScriptBin "alejandra" ''
      exec ${lib.getExe pkgs.alejandra} -qq "$@" .
    '';
  };
}
