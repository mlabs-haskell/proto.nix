{ pkgs, fourmolu }: {
  src = ./.;
  settings = { };

  hooks = {
    nixpkgs-fmt.enable = true;
    nix-linter.enable = true;
    cabal-fmt.enable = true;
    fourmolu.enable = true;
    shellcheck.enable = true;
    hlint.enable = true;
    typos.enable = true;
    markdownlint.enable = true;
    inherit (import ./src/hooks.nix { inherit pkgs; }) protolint txtpbfmt;
  };

  tools = { inherit fourmolu; };
}
