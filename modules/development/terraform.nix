{
  flake.homeModules.development = {
    config,
    lib,
    namespace,
    pkgs,
    ...
  }: {
    config = {
      home.sessionVariables = {
        TF_PLUGIN_CACHE_DIR = "${config.xdg.cacheHome}/terraform/plugin-cache";
        TF_CLI_CONFIG_FILE = "${config.xdg.configHome}/terraform/terraformrc";
        TF_OUTPUT_FILE = "tf.tfplan";
      };

      ${namespace}.shell.aliases = {
        tf = "terraform";
        tfp = "tf plan -out $TF_OUTPUT_FILE";
        tfa = "tf apply $TF_OUTPUT_FILE";
        tfpl = "tf state pull $(basename $PWD).tfstate > $(basename $PWD).state.json";
        tfo = "tf output -json";
      };

      programs.zsh.zsh-abbr.abbreviations = {
        "terraform a" = "terraform apply $TF_OUTPUT_FILE";
        "terraform i" = "terraform init -upgrade";
        "terraform o" = "terraform output -json";
        "terraform p" = "terraform plan -out $TF_OUTPUT_FILE";
        "terraform pl" = "terraform state pull $(basename $PWD).tfstate > $(basename $PWD).state.json";
      };
    };
  };

  perSystem = {
    inputs,
    pkgs,
    ...
  }: {
    devShells = let
      terraform = inputs.nixpkgs-terraform.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      tf = pkgs.mkShell {
        buildInputs = [terraform."1.13"];
      };
      tf-19 = pkgs.mkShell {
        buildInputs = [terraform."1.9"];
      };
      tf-15 = pkgs.mkShell {
        buildInputs = [terraform."1.5"];
      };
    };
  };
}
