# Repo wide settings
{ lib, flake-parts-lib, ... }:
{

  options = {

    perSystem = flake-parts-lib.mkPerSystemOption (
      { config, pkgs, ... }:
      {
        options.settings = {

          proto-lens-protoc = lib.mkOption {
            type = lib.types.package;
            description = "Haskell protoc plugin to use";
          };

        };

        config = {

          settings = {
            proto-lens-protoc = pkgs.haskellPackages.proto-lens-protoc;
          };
        };

      }
    );

  };

}
