# Haskell https://github.com/google/proto-lens/blob/master/proto-lens-protobuf-types/proto-lens-protobuf-types.cabal
{ pkgs, protobuf }:
let
  haskellProto = import ./haskell-proto.nix;

  anyHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/any.proto";
    cabalPackageName = "any-pb";
  };

  compilerPluginHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/compiler/plugin.proto";
    cabalBuildDepends = [ descriptorHsPb ];
    cabalPackageName = "compiler-plugin-pb";
  };

  descriptorHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/descriptor.proto";
    cabalPackageName = "descriptor-pb";
  };

  durationHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/duration.proto";
    cabalPackageName = "duration-pb";
  };

  emptyHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/empty.proto";
    cabalPackageName = "empty-pb";
  };

  wrappersHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/wrappers.proto";
    cabalPackageName = "wrappers-pb";
  };

  structHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/struct.proto";
    cabalPackageName = "struct-pb";
  };

  timestampHsPb = haskellProto {
    inherit pkgs;
    src = "${protobuf}/src";
    proto = "google/protobuf/timestamp.proto";
    cabalPackageName = "timestamp-pb";
  };

  # Google base protobufs
  googleHsPbs' = [
    timestampHsPb
    structHsPb
    wrappersHsPb
    emptyHsPb
    durationHsPb
    descriptorHsPb
    compilerPluginHsPb
    anyHsPb
  ];

  # Indexed by name for convenience
  googleHsPbs = with builtins; listToAttrs (map (value: { inherit (value) name; inherit value; }) googleHsPbs');

  # Formatted for haskell-nix
  googleHsPbsExtraHackage = with builtins; map toString googleHsPbs';
in
{ inherit googleHsPbs googleHsPbsExtraHackage; }
