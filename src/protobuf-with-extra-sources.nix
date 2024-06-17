{ lib
, protobuf
, writeShellScript
, extraSources
, linkFarm
, packageName ? "unspecified"
}:
let inherit (lib) getExe concatMapStringsSep;

  protocWithExtraSources = writeShellScript "${packageName}-protoc" ''
    ${getExe protobuf} ${concatMapStringsSep " " (s: "-I '${s}'") extraSources} $@
  '';
in
(linkFarm "${packageName}-protobuf" {
  "bin/protoc" = protocWithExtraSources;
  "include" = "${protobuf}/include";
  "lib" = "${protobuf}/lib";
  "nix-support" = "${protobuf}/nix-support";
}).overrideAttrs (_: _: {
  inherit (protobuf) version;
  meta.mainProgram = "protoc";
})
