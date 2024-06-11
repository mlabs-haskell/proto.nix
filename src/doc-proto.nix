pkgs: { src
      , protos ? [ ]
      , extraSources ? [ ]
      , extraSourcesDir ? ".extras"
      , docType ? "markdown"
      }:
let

  # Extra sources
  extra-sources = pkgs.linkFarm "extra-sources" (builtins.map (drv: { name = drv.name; path = drv; }) extraSources);

  hasExtraSources = builtins.length extraSources > 0;
  linkExtraSources = pkgs.lib.optionalString hasExtraSources ''
    echo "Linking extra sources"
    if [ -e ./${extraSourcesDir} ]; then rm ./${extraSourcesDir}; fi
    ln -s ${extra-sources} ./${extraSourcesDir}
  '';
in
pkgs.stdenv.mkDerivation {
  inherit src;
  name = "proto-docs";
  buildInputs = [
    pkgs.protobuf
  ];
  buildPhase = ''
    mkdir $out;
    ${linkExtraSources}
    protoc --plugin=${pkgs.protoc-gen-doc}/bin/protoc-gen-doc ${builtins.concatStringsSep " " protos} --doc_out=$out --doc_opt=${docType},api.md;
  '';
  dontInstall = true;
}
