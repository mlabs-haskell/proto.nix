# Repo-wide Nixpkgs with a ton of overlays
{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {

    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      inherit (inputs.haskell-nix) config;
      overlays = [
        inputs.haskell-nix.overlay
      ];
    };

  };
}
