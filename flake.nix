{
  description = "proto.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    haskell-nix.url = "github:input-output-hk/haskell.nix";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    protobuf = {
      url = "github:protocolbuffers/protobuf";
      flake = false;
    };

    http2-grpc-native = {
      url = "github:haskell-grpc-native/http2-grpc-haskell";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    hci-effects.url = "github:hercules-ci/hercules-ci-effects";
  };

  outputs =
    inputs@{ flake-parts, ... }:
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
        ./docs/build.nix
      ];
      debug = true;
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
