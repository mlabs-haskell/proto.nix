{
  description = "nix-protobuffers";

  inputs = {
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    protobuf = { url = "github:protocolbuffers/protobuf"; flake = false; };
    # TODO(bladyjoker): Merge with upstream and use that.
    http2-grpc-native = {
      url = "github:bladyjoker/http2-grpc-haskell";
      flake = false;
    };
    mlabs-tooling.url = "github:mlabs-haskell/mlabs-tooling.nix/bladyjoker/expose-modules";
  };

  outputs = { self, nixpkgs, haskell-nix, flake-utils, pre-commit-hooks, protobuf, mlabs-tooling, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      (system:
        let
          inherit self haskell-nix;

          pkgs = import nixpkgs {
            inherit system;
          };

          pkgsWithHaskellNix = import nixpkgs {
            inherit system;
            inherit (haskell-nix) config;
            overlays = [ haskell-nix.overlay ];
          };
          hnix = pkgsWithHaskellNix.haskell-nix;

          # pre-commit-hooks.nix
          fourmolu = pkgs.haskell.packages.ghc924.fourmolu;

          pre-commit-check = pre-commit-hooks.lib.${system}.run (import ./pre-commit-check.nix {
            inherit pkgs fourmolu;
          });

          # preCommitTools = pre-commit-hooks.outputs.packages.${system};

          preCommitDevShell = pkgs.mkShell {
            name = "pre-commit-env";
            inherit (pre-commit-check) shellHook;
          };

          # Proto env
          protoDevShell = import ./src/dev-shell.nix {
            inherit pkgs;
            inherit (pre-commit-check) shellHook;
          };

          # Haskell proto
          haskellProto = import ./src/haskell-proto.nix;

          # Haskell https://github.com/google/proto-lens/blob/master/proto-lens-protobuf-types/proto-lens-protobuf-types.cabal
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
          googleHsPbs = [
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
          googleHsPbs' = with builtins; listToAttrs (map (value: { inherit (drv) name; inherit value; }) googleHsPbs);

          # Formatted for haskell-nix
          googleHsPbsExtraHackage = with builtins; map toString googleHsPbs;

          # Haskell AddressBook
          addressBookHsPb = haskellProto {
            inherit pkgs;
            src = ./test-proto;
            proto = "addressbook.proto";
            cabalBuildDepends = [ googleHsPbs'.timestamp-pb ];
            cabalPackageName = "addressbook-pb";
          };

          addressBookHsProj = hnix.cabalProject' [
            mlabs-tooling.lib.mkHackageMod
            ({
              src = addressBookHsPb;
              compiler-nix-name = "ghc924"; # TODO(bladyjoker): Test with other GHC versions
              extraHackage = googleHsPbsExtraHackage;
            })
          ];
          addressBookHsFlake = addressBookHsProj.flake { };

          # Utilities
          # INFO: Will need this; renameAttrs = rnFn: pkgs.lib.attrsets.mapAttrs' (n: value: { name = rnFn n; inherit value; });
        in
        rec {
          # Useful for nix repl
          inherit pkgs;

          # Library
          lib = { inherit haskellProto googleHsPbs googleHsPbs' googleHsPbsExtraHackage; };

          # Standard flake attributes
          packages = { };

          devShells = rec {
            dev-pre-commit = preCommitDevShell;
            dev-proto = protoDevShell;
            default = preCommitDevShell;
          };

          # nix flake check --impure --keep-going --allow-import-from-derivation
          checks = { inherit pre-commit-check; } // devShells // packages // addressBookHsFlake.packages // googleHsPbs';
        }
      ) // {
      # Instruction for the Hercules CI to build on x86_64-linux only, to avoid errors about systems without agents.
      herculesCI.ciSystems = [ "x86_64-linux" ];
    };
}
