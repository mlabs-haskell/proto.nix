# proto.nix

Nix utilities for generating language-specific bindings from [Google Protocol
Buffers](https://developers.google.com/protocol-buffers) `.proto` files.

The intended goal is to enable
[Bazel-like](https://blog.bazel.build/2017/02/27/protocol-buffers.html) Google
Protobuf workflows with Nix.

Quick example showing how to build a Haskell Cabal and Markdown documentation package from a .proto schema:

```nix
let
  example-hs-pb = proto-nix.haskellProto {
    src = ./.;
    proto = "example.proto";
    cabalPackageName = "addressbook-pb";
  }

  example-api-docs = proto-nix.docProto {
    src = ./.;
    protos = ["example.proto"];
  }
```

## Overview

### src

Directory containing the implementation of PB Nix utilities (functions and flake-parts modules).

See the [build.nix](./src/build.nix) for available build outputs.

```shell
# Open the Nix REPL to inspect the Flake outputs
$ nix repl
# Inspects the `lib` functions
nix-repl> :lf .
nix-repl> lib.x86_64-linux.
lib.x86_64-linux.haskellProto
lib.x86_64-linux.preCommitFlakeModule
```

### google-pb

Directory containing the `protoc` generated libraries for [standard Google .proto schemas](https://github.com/protocolbuffers/protobuf/tree/main/src).

See the [build.nix](./google-pb/build.nix) for available build outputs.

```shell
# Builds the Google's descriptor.proto Haskell library
$ nix build .#descriptor-hs-pb
# Inspects the result
$ find result/
result/
result/descriptor-pb.cabal
result/src
result/src/Proto
result/src/Proto/Google
result/src/Proto/Google/Protobuf
result/src/Proto/Google/Protobuf/Descriptor.hs
result/src/Proto/Google/Protobuf/Descriptor_Fields.hs
```

### tests

Directory containing some tests and demonstration on how to use proto-nix.

```shell
# Builds the AddressBook canonical API Haskell library
$ nix build .#address-book-hs-pb
# Inspects the result
$ find result/
result/
result/addressbook-pb.cabal
result/addressbook.proto
result/src
result/src/Proto
result/src/Proto/Addressbook_Fields.hs
result/src/Proto/Addressbook.hs
```

### docs

Directory containing proto.nix (also auto generated) documentation.

```shell
# Builds the proto-nix book
$ nix build .#proto-nix-book
# Opens the generated documentation with Chrome
$ chromium result/index.html
```

## Getting started

### Installing Nix

This repository relies heavily on the [Nix Package
Manager](https://nixos.org/download.html) for both development and package
distribution.

To install run the following command:

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

and follow the instructions.

```sh
$ nix --version
nix (Nix) 2.8.0
```

> NOTE: The repository should work with Nix version greater or equal to 2.8.0.

Make sure to enable [Nix Flakes](https://nixos.wiki/wiki/Flakes#Enable_flakes)
and IFD by editing either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` on
your machine and add the following configuration entries:

```yaml
experimental-features = nix-command flakes
allow-import-from-derivation = true
```

Optionally, to improve build speed, it is possible to set up a binary caches
maintained by IOHK and Plutonomicon by setting additional configuration entries:

```yaml
substituters = https://cache.nixos.org https://iohk.cachix.org https://cache.iog.io https://public-plutonomicon.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= public-plutonomicon.cachix.org-1:3AKJMhCLn32gri1drGuaZmFrmnue+KkKrhhubQk/CWc=
```

### Building and development

To facilitate seamlessly moving between directories and associated Nix development shells we use [direnv](https://direnv.net) and [nix-direnv](https://github.com/nix-community/nix-direnv):

To install both using `nixpkgs`:

```sh
nix profile install nixpkgs#direnv
nix profile install nixpkgs#nix-direnv
```

Your shell and editors should pick up on the `.envrc` files in different directories and prepare the environment accordingly.
Use `direnv allow` to enable the direnv environment and `direnv reload` to reload it when necessary.

Additionally, throughout the repository one can use:

```sh
$ pre-commit run --all
cabal-fmt............................................(no files to check)Skipped
fourmolu.................................................................Passed
hlint....................................................................Passed
markdownlint.............................................................Passed
nix-linter...............................................................Passed
nixpkgs-fmt..............................................................Passed
shellcheck...........................................(no files to check)Skipped
typos....................................................................Passed
```

to run all the code quality tooling specified in the [Pre Commit hooks config file](./pre-commit.nix)
