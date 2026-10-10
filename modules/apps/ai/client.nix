{inputs, ...}: {
  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  perSystem = {pkgs, ...}: {
    devShells.ai = pkgs.mkShell {
      packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        crush
        opencode
        pi
      ];
    };
  };
}
