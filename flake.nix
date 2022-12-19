{
  description = "nix-protobuffers";

  inputs = {
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    protobuf = { url = "github:protocolbuffers/protobuf"; flake = false; };
    # TODO: Merge with upstream and use that.
    http2-grpc-native = {
      url = "github:bladyjoker/http2-grpc-haskell";
      flake = false;
    };
    mlabs-tooling.url = "github:mlabs-haskell/mlabs-tooling.nix/bladyjoker/expose-modules";
  };

  outputs = { self, nixpkgs, haskell-nix, flake-utils, pre-commit-hooks, protobuf, mlabs-tooling, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
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

        pre-commit-check = pre-commit-hooks.lib.${system}.run (import ./pre-commit-hooks.nix {
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

        # Haskell https://github.com/google/proto-lens/blob/master/proto-lens-protobuf-types/proto-lens-protobuf-types.cabal
        anyHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/any.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "any-pb";
        };

        compilerPluginHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/compiler/plugin.proto";
          cabalBuildDepends = [ descriptorHsPb ];
          cabalPackageName = "compiler-plugin-pb";
        };

        descriptorHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/descriptor.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "descriptor-pb";
        };

        durationHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/duration.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "duration-pb";
        };

        emptyHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/empty.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "empty-pb";
        };

        wrappersHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/wrappers.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "wrappers-pb";
        };

        structHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/struct.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "struct-pb";
        };

        timestampHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = "${protobuf}/src";
          proto = "google/protobuf/timestamp.proto";
          cabalBuildDepends = [ ];
          cabalPackageName = "timestamp-pb";
        };

        googlePbExtraHackage = with builtins; map toString [
          timestampHsPb
          structHsPb
          wrappersHsPb
          emptyHsPb
          durationHsPb
          descriptorHsPb
          compilerPluginHsPb
          anyHsPb
        ];

        # Haskell AddressBook
        addressBookHsPb = import ./src/protobuf-hs.nix {
          inherit pkgs;
          src = ./test-proto;
          proto = "addressbook.proto";
          cabalBuildDepends = [ timestampHsPb ];
          cabalPackageName = "addressbook-pb";
        };

        addressBookHsProj = hnix.cabalProject' [
          mlabs-tooling.lib.mkHackageMod
          ({
            src = addressBookHsPb;
            compiler-nix-name = "ghc924";
            extraHackage = googlePbExtraHackage;
          })
        ];
        addressBookHsFlake = addressBookHsProj.flake { };

        # Utilities
        # INFO: Will need this; renameAttrs = rnFn: pkgs.lib.attrsets.mapAttrs' (n: value: { name = rnFn n; inherit value; });
      in
      rec {
        # Useful for nix repl
        inherit pkgs googlePbExtraHackage;

        # Instruction for the Hercules CI to build on x86_64-linux only, to avoid errors about systems without agents.
        herculesCI.ciSystems = [ "x86_64-linux" ];

        # Standard flake attributes
        packages = { };

        devShells = rec {
          dev-pre-commit = preCommitDevShell;
          dev-proto = protoDevShell;
          default = preCommitDevShell;
        };

        # nix flake check --impure --keep-going --allow-import-from-derivation
        checks = { inherit pre-commit-check; } // devShells // packages // addressBookHsFlake.packages;
      }
    );
}
