{ inputs, ... }: {
  imports = [
    inputs.pre-commit-hooks.flakeModule # Adds perSystem.pre-commit options
  ];
  perSystem = { pkgs, ... }:
    {
      pre-commit.settings.hooks = {

        protolint = {
          enable = true;
          description = "Run protolint on all Google Protobuf files";
          name = "protolint";
          entry = "${pkgs.protolint}/bin/protolint lint -fix";
          files = "\\.proto$";
        };

        txtpbfmt = {
          enable = true;
          description = "Run txtpbfmt on all text Google Protobuf files";
          name = "txtpbfmt";
          entry = "${pkgs.txtpbfmt}/bin/txtpbfmt";
          files = "\\.(textproto|textpb)";
        };

      };
    };
}
