{
  description = "proto.nix";

  inputs = {
    haskell-nix.url = "github:input-output-hk/haskell.nix";

    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    protobuf = { url = "github:protocolbuffers/protobuf"; flake = false; };

    # TODO(bladyjoker): Merge with upstream and use that.
    http2-grpc-native = {
      url = "github:bladyjoker/http2-grpc-haskell";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    hci-effects.url = "github:hercules-ci/hercules-ci-effects";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./pkgs.nix
        ./settings.nix
        ./pre-commit.nix
        ./hercules-ci.nix
        ./src/build.nix
        ./src/dev-shell.nix
        ./google-pb/build.nix
        ./tests/api/build.nix
      ];
      debug = true;
      systems = [ "x86_64-linux" ]; # "x86_64-darwin"
    };
}

