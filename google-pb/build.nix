# Haskell https://github.com/google/proto-lens/blob/master/proto-lens-protobuf-types/proto-lens-protobuf-types.cabal
{ inputs, ... }:
{
  perSystem = { config, proto-nix, ... }:
    {
      packages = {

        any-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/any.proto" ];
          cabalPackageName = "any-pb";
        };

        compiler-plugin-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/compiler/plugin.proto" ];
          cabalBuildDepends = [ config.packages.descriptor-hs-pb ];
          cabalPackageName = "compiler-plugin-pb";
        };

        descriptor-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/descriptor.proto" ];
          cabalPackageName = "descriptor-pb";
        };

        duration-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/duration.proto" ];
          cabalPackageName = "duration-pb";
        };

        empty-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/empty.proto" ];
          cabalPackageName = "empty-pb";
        };

        wrappers-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/wrappers.proto" ];
          cabalPackageName = "wrappers-pb";
        };

        struct-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/struct.proto" ];
          cabalPackageName = "struct-pb";
        };

        timestamp-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/timestamp.proto" ];
          cabalPackageName = "timestamp-pb";
        };

        google-hs-pb = proto-nix.haskellProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/any.proto" "google/protobuf/compiler/plugin.proto" "google/protobuf/descriptor.proto" "google/protobuf/duration.proto" "google/protobuf/empty.proto" "google/protobuf/wrappers.proto" "google/protobuf/struct.proto" "google/protobuf/timestamp.proto" ];
          cabalPackageName = "google-pb";
        };

        google-pb-docs = proto-nix.docProto {
          src = "${inputs.protobuf}/src";
          protos = [ "google/protobuf/any.proto" "google/protobuf/compiler/plugin.proto" "google/protobuf/descriptor.proto" "google/protobuf/duration.proto" "google/protobuf/empty.proto" "google/protobuf/wrappers.proto" "google/protobuf/struct.proto" "google/protobuf/timestamp.proto" ];
        };

      };

    };
}
