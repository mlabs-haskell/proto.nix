{ config, flake-parts-lib, lib, ... }: {

  # Makes a system agnostic option (dunno why I needed this).
  options.proto-nix = lib.mkOption {
    type = lib.types.anything; # probably not the best type
    default = { };
  };

  # Makes it available in the system agnostic `proto-nix` argument.
  # TODO(bladyjoker): This is not available in module function argument :shrug:
  config._module.args.proto-nix = config.proto-nix;

  # Sets the above set option to system ones.
  config.proto-nix = lib.genAttrs config.systems (system: (config.perSystem system).proto-nix);

  # Makes `lib.x86_64-linux.xyz` available
  config.flake.lib = config.proto-nix // {
    preCommitModule = ./pre-commit-hooks.nix;
  };

  options = {

    # Makes a per system `proto-nix` option.
    perSystem = flake-parts-lib.mkPerSystemOption
      ({ pkgs, config, ... }: {

        options.proto-nix = lib.mkOption {
          type = lib.types.anything;
          default = { };
        };

        # Sets a per system `proto-nix` option.
        config = {
          proto-nix = {
            # NOTE(bladyjoker): If you need to add a function the export externally and use internally via config.proto-nix, add it here.
            haskellProto = import ./haskell-proto.nix pkgs config.settings.proto-lens-protoc;
            docProto = import ./doc-proto.nix pkgs;
            rustProto = import ./rust-proto.nix pkgs;
            combinedProto = import ./combined.nix pkgs config.settings.proto-lens-protoc;
          };

          # Makes it available in the per system `proto-nix` argument.
          _module.args.proto-nix = config.proto-nix;

        };

      });

  };
}
