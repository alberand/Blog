let
  pkgs = import (pkgsSrc) {};
  pkgsLocal = import <nixpkgs> {};
  pkgsSrc = pkgsLocal.fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/82a3ab0dd25d535e556abf7e7f676627217edc07.zip";
    sha256 = "0xlpkys7pc1riqlfii6hv09wmnalnj0q6qyb5mwyxgzlghi9mixh";
  };

  pelican_plugins = pkgs.fetchFromGitHub {
    owner = "getpelican";
    repo = "pelican-plugins";
    rev = "000fc5a";
    sha256 = "1955plbgzc5zq6rg054jaaj7fzq7k5w1szwy85c1mmvsq5xkzc63";
  };

in pkgs.stdenv.mkDerivation {
    inherit pelican_plugins;

    name = "alberand-com";
    src = ./.;

    buildInputs = with pkgs.python3Packages; [ 
	    pelican markdown pelican_plugins 
    ];

    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      mkdir $out/output
      substitute $src/pelicanconf_template.py $TMPDIR/pelicanconf_nix.py --subst-var pelican_plugins
      cd $src
      make OUTPUTDIR=$out/output CONFFILE=$TMPDIR/pelicanconf_nix.py html
      cp -R --no-preserve=mode,ownership $src/* $out
      chmod +x $out/develop_server.sh
      cp --no-preserve=mode,ownership $TMPDIR/pelicanconf_nix.py $out/pelicanconf.py
    '';
  }
