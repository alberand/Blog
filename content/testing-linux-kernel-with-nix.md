Title: Testing Linux Kernel with Nix
Date: 06.05.2023
Modified: 06.05.2023
Status: draft
Tags: nix, linux, kernel, testing, fstests
Keywords: linux, kernel, testing, fstests
Slug: testing-linux-kernel-with-nix
Author: Andrey Albershtein
Summary: Nix provides very flexible Virtual machines, this articles describe how
to create a VM which will automatically run fstests with modified Linux kernel.
Lang: en

While working on one of the XFS feature in Linux kernel I had a hard time firing
up VMs for testing. I didn't have well configured image to easily boot up QEMU
with path to my newly compiled kernel and have it run a few simple tests. I've
decided to try NixOS with its quite amazing VMs. My goal was to simplify testing
kernel to one command.

My goal process had to look like this:
- I modify my kernel in `./linux` directory
- Then I modify userspace tools which VM will use to test the kernel - in my
  case this was [xfsprogs][]
- Then I add new tests which VM will use to run the kernel - in my case this was
  [fstests][]
- Run the `vmtest` command which will fire-up VM which will run my tests

# Project structure

As I want custom command in my `./linux` directory I went with Nix's flake and
`direnv` utility. The flake defines development shell with all dependencies
necessary for working\compiling the kernel. The `direnv` automatically activates
this shell when I enter `./linux`.

But also I don't want to complicate this flake too much. As my `flake.nix` won't
be accepted upstream I will always need to copy it from one dir to another. So
it must be one simple file. What I can do is define everything in another flake
and include it as input.

I called this input flake - nix-kernel-vm. This flake will define everything
what we need and flake in the kernel will just call to it with a few parameters.

## Linux Kernel Flake

Let's start with the simple one. While working with the kernel we want to
specify which tests to use and which userspace tools to use to testit.

```nix
{
  description = "Linux Kernel development env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-kernel-vm.url = "github:alberand/nix-kernel-vm";
  };

  outputs = { self, nixpkgs, flake-utils, nix-kernel-vm }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    root = builtins.toString ./.;
  in rec {
    devShells.default = nix-kernel-vm.lib.mkLinuxShell {
      inherit pkgs;
      root = root;
      xfstests-src = fetchGit /home/alberand/Projects/xfstests-dev;

      xfsprogs-src = pkgs.fetchFromGitHub {
        owner = "alberand";
        repo = "xfsprogs";
        rev = "91bf9d98df8b50c56c9c297c0072a43b0ee02841";
        sha256 = "sha256-otEJr4PTXjX0AK3c5T6loLeX3X+BRBvCuDKyYcY9MQ4=";
      };
    };
  });
}
```

Next we need to tell `direnv` that it should use devShell from this flake.
Moreover, this flake is impure as we use local sources (it's not reproducible).
To achieve this create `.envrc` with `use flake . --impure`.

```shell
echo "use flake . --impure" > .envrc
```

Right after that direnv will warn you that you have to allow to activate
environment in this directory with `direnv allow` command.

## nix-kernel-vm - definition of VM

This is much more complicated flake which defines VM itself and all the
necessary `lib.` functions to use this flake.

# References

[0]: https://git.kernel.org/pub/scm/fs/xfs/xfsprogs-dev.git/
[1]: https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git
