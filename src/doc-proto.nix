pkgs: { src
      , protos ? [ ]
      , extraSources ? [ ]
      , docType ? "markdown"
      }:
let

  ourProtobuf = pkgs.callPackage ./protobuf-with-extra-sources.nix {
    inherit extraSources;
  };
in
pkgs.stdenv.mkDerivation {
  inherit src;
  name = "proto-docs";
  buildInputs = [
    ourProtobuf
  ];
  buildPhase = ''
    mkdir $out;
    protoc --plugin=${pkgs.protoc-gen-doc}/bin/protoc-gen-doc \
      -I . \
      --doc_out=$out \
      --doc_opt=${docType},api.md \
      ${builtins.concatStringsSep " " protos};
  '';
  dontInstall = true;
}
