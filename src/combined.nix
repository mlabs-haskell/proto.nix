pkgs: proto-lens-protoc: { src
                         , packageName
                         , packageVersion ? "1.0.0"
                         , protos ? [ ]
                         , generatedLibs ? [ ]
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
      (builtins.elem "rust" generatedLibs)
      {
        "${packageName}-rust" =
          rustProto
            {
              inherit src protos extraSources extraSourcesDir;
              crateName = packageName;
              cabalPackageVersion = packageVersion;
            };
      };

  haskellPkg =
    pkgs.lib.optionalAttrs
      (builtins.elem "haskell" generatedLibs)
      {
        "${packageName}-haskell" =
          haskellProto
            {
              inherit src protos extraSources extraSourcesDir packageName cabalBuildDepends useGoogleProtosFromHackage;
              cabalPackageName = packageName;
              cabalPackageVersion = "1.${packageName}";
            };
      };

  docPkg = {
    "${packageName}-doc" =
      docProto
        {
          inherit src protos docType;
        };
  };

  # Extra sources
  extra-sources = pkgs.linkFarm "extra-sources" (builtins.map (drv: { name = drv.name; path = drv; }) extraSources);

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

  packages = rustPkg // haskellPkg // docPkg;
}
