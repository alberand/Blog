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
a derivation a defined in `derivation.nix` with `stdenv.mkDerivation`. Here is
oneliner:

```nix
nix-build -E 'with import <nixpkgs> { }; callPackage ./derivation.nix { }'
```

You can also put this expression into default.nix and run with just `nix-build`.
The `-K` will leave nix-build-derivation-ver directory in `/tmp` so you can
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

This is because your local copy is probably dirty (nix does `cp` which copies
all the stuff). In some cases running `make clean` will save you. Or you can
fetch your local branch:

```nix
src = fetchgit {
    url = ./.;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
```

But note that you will need to commit all your changes.

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
some changes to the branch. But forgot to tell nix that the branch was changed:

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
