{...}: let
  mkScripts = pkgs:
    with pkgs; [
      (writeShellApplication {
        name = "helm-template";
        runtimeInputs = [kubernetes-helm yq-go];
        text = ''
          chart=''${1:-$HR_DEFAULT_CHART}
          hr=''${2:-$HR_DEFAULT_HR}
          helm template \
            -f <(yq .spec.values "$hr") \
            "$(yq .metadata.name "$hr")" \
            "$chart"
        '';
      })
      (writeShellApplication {
        name = "kubectl-get-nodes-version";
        runtimeInputs = [kubectl];
        text = ''
          kubectl get nodes --no-headers \
            -o custom-columns="VERSION:.status.nodeInfo.kubeletVersion,LABEL:.spec.taints[0].value,NODE:.metadata.name" "$@" | \
              sort --version-sort
        '';
      })
    ];
in {
  flake.homeModules.development = {pkgs, ...}: {
    home.packages = mkScripts pkgs;
  };

  perSystem = {pkgs, ...}: {
    devShells.kubernetes = pkgs.mkShell {
      packages = mkScripts pkgs;
    };
  };
}
