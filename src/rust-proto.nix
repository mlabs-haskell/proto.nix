pkgs: { src
      , protos ? [ ]
      , extraSources ? [ ]
      , extraSourcesDir ? ".extras"
      , rustCrateName
      , rustCrateVersion ? "0.1.0"
      }:
let inherit (pkgs)
  # NOTE(chfanghr): I'd love to switch to callPackage pattern
  stdenv
  protoc-gen-tonic
  protoc-gen-prost
  protoc-gen-prost-crate
  writeText
  protobuf;

  inherit (pkgs) lib;

  inherit (lib) concatStringsSep sourceFilesBySuffices;

  cargoTemplate = writeText "rust-cargo-template-${rustCrateName}-${rustCrateVersion}" ''
    [package]
    name = "${rustCrateName}"
    version = "${rustCrateVersion}"
    edition = "2021"

    [dependencies]
    prost = "0.12.0"
    prost-types = "0.12.3"
    pbjson-types = "0.6"
    serde = "1.0"
    tonic = { version = "0.11", features = ["gzip"] }
  '';

  cleanSrc = sourceFilesBySuffices src [ ".proto" ];

  protoFiles = concatStringsSep " " protos;

  # Extra sources
  extra-sources = pkgs.linkFarm "extra-sources" (builtins.map (drv: { name = drv.name; path = drv; }) extraSources);

  hasExtraSources = builtins.length extraSources > 0;
  linkExtraSources = pkgs.lib.optionalString hasExtraSources ''
    echo "Linking extra sources"
    if [ -e ./${extraSourcesDir} ]; then rm ./${extraSourcesDir}; fi
    ln -s ${extra-sources} ./${extraSourcesDir}
  '';

in
stdenv.mkDerivation {
  src = cleanSrc;
  name = rustCrateName;
  version = rustCrateVersion;

  buildInputs = [
    protobuf
    protoc-gen-prost
    protoc-gen-tonic
    protoc-gen-prost-crate
  ];

  buildPhase = ''
    set -vox
    ${linkExtraSources}
    mkdir -p gen/src
    protoc --prost_out=gen/src \
            --tonic_out=gen/src \
            --prost-crate_out=gen \
            --prost-crate_opt=gen_crate=${cargoTemplate}\,no_features=true \
            -I . \
            ${protoFiles}
  '';

  installPhase = ''
    cp -r gen $out
  '';

}
