{ pkgs, shellHook }:
pkgs.mkShell {
  name = "protobufs-nix-proto-env";
  buildInputs = [
    pkgs.protobuf
    pkgs.protolint
    pkgs.txtpbfmt
    pkgs.haskellPackages.proto-lens-protoc
  ];

  inherit shellHook;
}
