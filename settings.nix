# Repo wide settings
{ lib, flake-parts-lib, ... }: {

  options = {

    perSystem = flake-parts-lib.mkPerSystemOption
      ({ config, pkgs, ... }: {
        options.settings = {

          proto-lens-protoc = lib.mkOption {
            type = lib.types.package;
            description = "Haskell protoc plugin to use";
          };

        };

        config = {

          settings = {
            # WARN(bladyjoker): Using recent versions fails because `ghc-source-gen` is marked as broken.
            # Unfortunately, this means yet another GHC in your Nix store -.-
            proto-lens-protoc = pkgs.haskell.packages.ghc810.proto-lens-protoc;
          };
        };

      });

  };

}
