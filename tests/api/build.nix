_:
{
  perSystem = { config, proto-nix, ... }:
    {
      packages = {
        address-book-hs-pb = proto-nix.haskellProto {
          src = ./.;
          proto = "addressbook.proto";
          cabalBuildDepends = [ config.packages.timestamp-hs-pb ];
          cabalPackageName = "addressbook-pb";
        };
      };

    };
}
