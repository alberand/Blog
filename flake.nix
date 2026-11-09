{
  description = "alberand blog";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkSite = pkgs: { name, conf }: pkgs.stdenv.mkDerivation {
        inherit name;
        src = with pkgs.lib.fileset; toSource {
          root = ./.;
          fileset = unions [
            ./content
            ./theme
            ./pelicanconf.py
            ./publishconf.py
          ];
        };
        nativeBuildInputs = [ (pkgs.python3.withPackages (p: [ p.pelican p.markdown ])) ];
        LC_ALL = "en_US.UTF-8";
        buildPhase = "pelican content -o output -s ${conf}";
        installPhase = "mv output $out";
      };

      scripts = pkgs: {
        build = pkgs.writeShellScriptBin "build" ''
          exec nix build --print-build-logs "$@"
        '';

        serve = pkgs.writeShellScriptBin "serve" ''
          set -euo pipefail
          nix build .#
          exec ${pkgs.python3}/bin/python -m http.server -d result "$@"
        '';

        publish = pkgs.writeShellScriptBin "publish" ''
          set -euo pipefail
          nix build .#prod --print-build-logs
          stage="/tmp/blog-$$"
          ssh door.vps "rm -rf '$stage' && mkdir '$stage'"
          rsync -az --delete --info=progress2 result/ "door.vps:$stage/"
          ssh door.vps "sudo rsync -a --delete '$stage/' /var/www/blog/ \
            && sudo chown -R caddy:caddy /var/www/blog \
            && sudo chmod -R u+w,g+w,o-r /var/www/blog \
            && rm -rf '$stage'"
        '';

        new = pkgs.writeShellScriptBin "new" ''
          if [ "$#" -ne 1 ]; then
            echo "Specify article name"
            exit 1
          fi

          cat <<EOF > "content/$1.md"
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

        lint = pkgs.writeShellScriptBin "lint" ''
          files=$(git ls-files -m content)
          if [ -n "$files" ]; then
            exec ${pkgs.proselint}/bin/proselint $files
          fi
        '';
      };
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in rec {
          site = mkSite pkgs { name = "alberand-com-dev"; conf = "pelicanconf.py"; };
          prod = mkSite pkgs { name = "alberand-com"; conf = "publishconf.py"; };
          default = site;
        });

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          s = scripts pkgs;
          app = name: { type = "app"; program = "${s.${name}}/bin/${name}"; };
        in {
          default = app "serve";
          build = app "build";
          serve = app "serve";
          publish = app "publish";
          new = app "new";
          lint = app "lint";
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = pkgs.mkShell {
            packages = [
              (pkgs.python3.withPackages (p: [ p.pelican p.markdown ]))
              pkgs.proselint
            ];
          };
        });
    };
}
