{
  flake.nixosModules.organization = {namespace, ...}: {
    ${namespace}.organization.orgs.dev = {
      user.id = 1337;
    };
  };
}
