Title: Nix common issues
Date: 13.09.2023
Modified: 16.10.2023
Status: published
Tags: nix, faq, common problems, nixos, nixpkgs
Keywords: nix, faq, common problems, nixos, nixpkgs
Slug: nix-notes
Author: Andrey Albershtein
Summary: This is collection of common problems I face working with Nix packages
Lang: en

This is collection of common problems/issues I faced working with Nix packages
or on NixOS. I find it quite difficult to find necessary information in Nix
reference as it missing or hidden too deep in the text.

## I just want to build a derivation

From time to time I google for an expression to put into `default.nix` to build
a derivation defined in `derivation.nix`. Here is oneliner:

```shell
nix-build -E 'with import <nixpkgs> { }; callPackage ./derivation.nix { }'
```

You can also put this expression into default.nix and run with just `nix-build`.
The `-K` will create nix-build-derivation-ver directory in `/tmp` so you can
debug it.

## shell.nix example

I'm always looking for `shell.nix` example which I create almost in every
project:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  # runtime deps
  buildInputs = [
    hello
  ];
}
```

## Why src = ./.; fails but src = fetchFromGithub {...} not?

This is because your local copy is probably dirty; nix does `cp` which copies
all stuff to /nix/store. In some cases running `make clean` will save you. But I
would suggest using git to fetch your local branch:

```nix
src = fetchgit {
    url = ./.;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
```

Note that you will need to commit all your changes.

## error: cycle detected in build of '/nix/store/xxx.drv' in the references of output 'bin' from output 'out'

Don't know what this error is about but I solved it by removing "bin" from the
`outputs`:

```nix
{ pkgs ? import <nixpkgs> {} }:
with pkgs; stdenv.mkDerivation rec {

  ...

  #          "bin" was here
  #          v
  outputs = [ "dev" "out" "doc" ];

  ...

}
```

## Flake input is not the latest commit

From time to time results of the `nix build .#` didn't have the latest inputs.
This probably happens because use specified your input as a git branch and did
some changes to the branch. But forgot to tell nix that the branch was changed
(with `nix flake update`):

```nix
...
inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #                                        vvvvvvvvvvvvvvvvvv
    xfsprogs.url = "github:alberand/xfsprogs?branch=fsverity-v2";
    xfsprogs.flake = false;
}
...
```

The solution to this is always use `rev=<commit hash>` to pinpoint flake's
inputs.

## Force rebuild (download sources)

When running something like `nix run github:alberand/nix-kernel-vm` nix will
download the source code. Unfortunately, if repository is updated right after
that, nix will not re-download new version if command is run again. I haven't
found a way to force nix do it except asking garbage collector to clean the
whole `/nix/store`:

```shell
nix-store -gc
```

Note that this command remove only unused packages (ones which are not installed
into the system).
