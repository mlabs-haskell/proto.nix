_:
{
  perSystem = { pkgs, config, ... }:
    {

      devShells.dev-proto-nix = pkgs.mkShell {
        name = "dev-proto-nix";
        buildInputs = [
          pkgs.protobuf
          pkgs.protolint
          pkgs.txtpbfmt
          config.settings.proto-lens-protoc
        ];

      };
    };
}
