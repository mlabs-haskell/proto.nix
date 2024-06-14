{ lib
, protobuf
, writeShellScript
, extraSources
, linkFarm
, packageName ? "unspecified"
}:
let inherit (lib) getExe concatMapStringsSep;
  ourProtocScriptName = "${packageName}-protoc";

  ourProtoc = writeShellScript ourProtocScriptName ''
    ${getExe protobuf} ${concatMapStringsSep " " (s: "-I '${s}'") extraSources} $@
  '';
in
(linkFarm "${packageName}-protobuf" {
  "bin/protoc" = ourProtoc;
  "include" = "${protobuf}/include";
  "lib" = "${protobuf}/lib";
  "nix-support" = "${protobuf}/nix-support";
}).overrideAttrs (_: _: {
  inherit (protobuf) version;
  meta.mainProgram = "protoc";
})
