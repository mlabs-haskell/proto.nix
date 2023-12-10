_: {
  perSystem = { pkgs, config, ... }:
    {
      devShells.dev-docs = pkgs.mkShell {
        name = "docs-env";
        packages = [ pkgs.mdbook ];
      };

      packages.proto-nix-book = pkgs.stdenv.mkDerivation {
        src = ./.;
        name = "proto-nix-book";
        buildInputs = [ pkgs.mdbook ];
        buildPhase = ''
          cp ${config.packages.address-book-docs}/api.md address-book-api.md;
          cp ${config.packages.google-pb-docs}/api.md google-api.md;
          mdbook build . --dest-dir $out
        '';
      };

    };
}
