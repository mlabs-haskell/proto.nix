pkgs: proto-lens-protoc: { src
                         , protos ? [ ]
                         , extraSources ? [ ]
                         , cabalPackageName
                         , cabalPackageVersion ? "0.1.0.0"
                         , cabalBuildDepends ? [ ]
                         , useGoogleProtosFromHackage ? false
                         }:
let
  depPackageNames = builtins.map (dep: dep.name) cabalBuildDepends;
  cabalTemplate = pkgs.writeTextFile {
    name = "protobuf-hs-cabal-template";
    text = ''
      cabal-version:      3.0
      name:               ${cabalPackageName}
      version:            ${cabalPackageVersion}
      synopsis:           A Cabal project that contains protoc/proto-lens-protoc generated Haskell modules
      build-type:         Simple

      library
          exposed-modules: EXPOSED_MODULES
          autogen-modules: EXPOSED_MODULES

          hs-source-dirs:     src

          default-language: Haskell2010
          build-depends:
              base,
              proto-lens-runtime,
              ${if useGoogleProtosFromHackage then "proto-lens-protobuf-types," else ""}${builtins.concatStringsSep "," depPackageNames}
    '';
  };

  protobufWithExtraSources = pkgs.callPackage ./protobuf-with-extra-sources.nix {
    packageName = cabalPackageName;
    inherit extraSources;
  };
in
pkgs.stdenv.mkDerivation {
  src = builtins.filterSource (path: _: pkgs.lib.strings.hasSuffix ".proto" path) src;
  name = cabalPackageName;
  buildInputs = [
    protobufWithExtraSources
  ];
  buildPhase = ''
    set -vox
    mkdir src
    protoc --plugin=protoc-gen-haskell=${proto-lens-protoc}/bin/proto-lens-protoc \
           --proto_path=${src} \
           --haskell_out=src \
           ${builtins.concatStringsSep " " (builtins.map (proto: "${src}/${proto}") protos)}

    EXPOSED_MODULES=$(find src -name "*.hs" | while read f; do grep -Eo 'module\s+\S+\s+' $f | head -n 1 | sed -r 's/module\s+//' | sed -r 's/\s+//'; done | tr '\n' ' ')
    echo "Found generated modules $EXPOSED_MODULES"
    cat ${cabalTemplate} | sed -r "s/EXPOSED_MODULES/$EXPOSED_MODULES/" > ${cabalPackageName}.cabal
  '';

  installPhase = ''
    cp -r . $out
  '';
}
