{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [
        (inputs.import-tree ./modules)
      ];

      systems = import inputs.systems;
      _module.args.lib = inputs.nixpkgs.lib.extend (_: _: config.flake.lib);
    })
  '';
}
