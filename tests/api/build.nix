_:
{
  perSystem = { config, proto-nix, ... }:
    {
      packages = {
        address-book-hs-pb = proto-nix.haskellProto {
          src = ./.;
          protos = [ "addressbook.proto" ];
          cabalBuildDepends = [ config.packages.timestamp-hs-pb ];
          cabalPackageName = "addressbook-pb";
        };

        address-book-rust-pb = proto-nix.rustProto {
          src = ./.;
          protos = [ "addressbook.proto" ];
          rustCrateName = "addressbook-pb";
        };

        address-book-docs = proto-nix.docProto {
          src = ./.;
          protos = [ "addressbook.proto" ];
        };
      };

    };
}
