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
      publish = pkgs.writeScriptBin "publish" (builtins.readFile ./publish);
      blog = blog.blog-dev;
      pub-blog = blog.blog-pub;
      new = pkgs.writeScriptBin "new" ''
        #!/usr/bin/env bash

        if [ "$#" -ne 1 ]; then
          echo "Specify artiicle name"
          exit 1
        fi

        DIR=$(pwd)
        cat <<EOF > "$DIR/content/$1.md"
Title: Template
Date: $(date '+%d.%m.%Y')
Modified: $(date '+%d.%m.%Y')
Status: draft
Tags: pelican, publishing
Keywords: pelican, publishing
Slug: $1
Author: Andrey Albershtein
Summary: Short version for index and feeds
Lang: en

This is the content of my super blog post.
EOF
      '';
    });

    packages = {
      default = pkgs.blog;
      blog = pkgs.blog;
      pub-blog = pkgs.pub-blog;
    };

    apps.default = flake-utils.lib.mkApp {
      drv = pkgs.serve;
    };

    devShells = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pkgs.serve
          pkgs.publish
          pkgs.new
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
