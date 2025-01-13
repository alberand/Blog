Title: Updating and developing NixOS packages
Date: 13.01.2025
Modified: 13.01.2025
Status: published
Tags: NixOS, package, nix
Keywords: NixOS, package, nix
Slug: updating-nixos-packages
Author: Andrey Albershtein
Summary: Short guide on developing and updating NixOS packages in nixpkgs repository
Lang: en

Useful links:

- [Very useful guide on Nixos Wiki][1]
- [Good manual on stackexchange.com on creating NixOS package][2]

[1]: https://nixos.wiki/wiki/Nixpkgs/Create_and_debug_packages
[2]: https://unix.stackexchange.com/questions/717168/how-to-package-my-software-in-nix-or-write-my-own-package-derivation-for-nixpkgs

First of all create your environment

```console
    $ git clone xxx
    $ cd nixpkgs
    $ git checkout update-package
    $ export NIXPKGS=$(pwd)
```

Build a packages

```console
    $ nix-build $NIXPKGS -k -A xfsprogs
```

Run shell with your new updated packages and play around with it to make sure it
works:

```console
    $ nix-shell -I nixpkgs=$NIXPKGS -p xfsprogs
    ...
    $ mkfs.xfs -V
    mkfs.xfs version 6.12.0
```

