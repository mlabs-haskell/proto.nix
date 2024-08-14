pkgs: proto-lens-protoc: { src
                         , packageName
                         , packageVersion ? "1.0.0"
                         , protos ? [ ]
                         , langs ? [ ]
                         , extraSources ? [ ]
                         , cabalBuildDepends ? [ ]
                         , useGoogleProtosFromHackage ? false
                         , docType ? "markdown"
                         }:
let

  haskellProto = import ./haskell-proto.nix pkgs proto-lens-protoc;
  docProto = import ./doc-proto.nix pkgs;
  rustProto = import ./rust-proto.nix pkgs;

  rustPkg =
    pkgs.lib.optionalAttrs
      (builtins.elem "rust" langs)
      {
        "${packageName}-rust" =
          rustProto
            {
              inherit src protos extraSources;
              rustCrateName = packageName;
              rustCrateVersion = packageVersion;
            };
      };

  haskellPkg =
    pkgs.lib.optionalAttrs
      (builtins.elem "haskell" langs)
      {
        "${packageName}-haskell" =
          haskellProto
            {
              inherit src protos extraSources cabalBuildDepends useGoogleProtosFromHackage;
              cabalPackageName = packageName;
              cabalPackageVersion = "1.${packageVersion}";
            };
      };

  otherPkgs = {
    "${packageName}-doc" =
      docProto
        {
          inherit src protos extraSources docType;
        };

    "${packageName}-src" =
      pkgs.lib.cleanSourceWith {
        name = "${packageName}-${packageVersion}";
        inherit src; filter = pkgs.lib.cleanSourceFilter;
      };
  };

  protobufWithExtraSources = pkgs.callPackage ./protobuf-with-extra-sources.nix {
    inherit packageName extraSources;
  };
in
{
  devShells."dev-${packageName}" = pkgs.mkShell {
    name = "dev-${packageName}";
    buildInputs = [
      protobufWithExtraSources
      pkgs.protolint
      pkgs.txtpbfmt
      proto-lens-protoc
    ];
  };

  packages = rustPkg // haskellPkg // otherPkgs;
}
