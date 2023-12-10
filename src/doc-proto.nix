pkgs: { src, protos ? [ ], docType ? "markdown" }:
pkgs.stdenv.mkDerivation {
  inherit src;
  name = "proto-docs";
  buildInputs = [
    pkgs.protobuf
  ];
  buildPhase = ''
    mkdir $out;
    protoc --plugin=${pkgs.protoc-gen-doc}/bin/protoc-gen-doc ${builtins.concatStringsSep " " protos} --doc_out=$out --doc_opt=${docType},api.md;
  '';
}
