pkgs: proto-lens-protoc: { src
                         , packageName
                         , packageVersion ? "1.0.0"
                         , protos ? [ ]
                         , langs ? [ ]
                         , extraSources ? [ ]
                         , extraSourcesDir ? ".extras"
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
              inherit src protos extraSources extraSourcesDir;
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
              inherit src protos extraSources extraSourcesDir cabalBuildDepends useGoogleProtosFromHackage;
              cabalPackageName = packageName;
              cabalPackageVersion = "1.${packageName}";
            };
      };

  otherPkgs = {
    "${packageName}-doc" =
      docProto
        {
          inherit src protos docType;
        };

    "${packageName}-src" =
      pkgs.lib.cleanSourceWith {
        name = "${packageName}-${packageVersion}";
        inherit src; filter = pkgs.lib.cleanSourceFilter;
      };
  };

  # Extra sources
  extra-sources = pkgs.linkFarm "extra-sources" (builtins.map
    (drv: {
      name = drv.name;
      path = drv;
    })
    extraSources);

  hasExtraSources = builtins.length extraSources > 0;
  linkExtraSources = pkgs.lib.optionalString hasExtraSources ''
    echo "Linking extra sources"
    if [ -e ./${extraSourcesDir} ]; then rm ./${extraSourcesDir}; fi
    ln -s ${extra-sources} ./${extraSourcesDir}
  '';

in
{
  devShells."dev-${packageName}" = pkgs.mkShell {
    name = "dev-${packageName}";
    buildInputs = [
      pkgs.protobuf
      pkgs.protolint
      pkgs.txtpbfmt
      proto-lens-protoc
    ];
    shellHook = linkExtraSources;
  };

  packages = rustPkg // haskellPkg // otherPkgs;
}
