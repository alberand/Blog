{
  description = "alberand blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ self.overlays.${system}.default ];
    };
    blog = (import ./derivation.nix { inherit self pkgs; });
  in rec {
    overlays.default = (final: prev: {
      serve = pkgs.writeScriptBin "serve" ''
#!/usr/bin/env bash

python -m http.server --directory result
      '';
      blog = blog.blog-dev;
      publish = blog.blog-pub;
    });

    packages.${system} = {
      default = pkgs.blog;
      publish = pkgs.publish;
    };

    apps.${system}.default = flake-utils.lib.mkApp {
      drv = pkgs.serve;
    };

    devShells = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pkgs.serve
        ];

        buildInputs = with pkgs; [
          (pkgs.python3.withPackages
          (pythonPackages: with pythonPackages; [
            pelican
            markdown
          ])
          )
        ];
      };
    };
  });
}
