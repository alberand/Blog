{ self, pkgs ? import nixpkgs {} }:
let
  blog-dev = pkgs.stdenv.mkDerivation {
    name = "alberand-com";
    src = ./.;

    buildInputs = with pkgs.python3Packages; [
      pelican
      markdown
      pkgs.proselint
      pygments-markdown-lexer
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      pelican
      markdown
    ];

    LC_ALL = "en_US.UTF-8";

    buildPhase = ''
                        cp pelicanconf.py $TMPDIR/pelicanconf.py
                        #substitute $src/pelicanconf.py $TMPDIR/pelicanconf.py \
                                #--subst-var pelican_plugins
                        make CONFFILE=$TMPDIR/pelicanconf.py html
    '';

    installPhase = ''
                        # Copy the generated result
                        mkdir -p $out
                        cp -r "output/"* $out
                        cp --no-preserve=mode,ownership $src/develop_server.sh $out
                        chmod +x $out/develop_server.sh
                        cp --no-preserve=mode,ownership $src/serve $out
                        chmod +x $out/serve
                        cp --no-preserve=mode,ownership $TMPDIR/pelicanconf.py $out/pelicanconf.py
                        cd $out
    '';
  };

in {
  blog-dev = blog-dev;
  blog-pub = blog-dev.overrideAttrs (oldAttrs: {
    buildPhase = ''
                        cp pelicanconf.py $TMPDIR/pelicanconf.py
                        cp publishconf.py $TMPDIR/publishconf.py
                        #substitute $src/pelicanconf.py $TMPDIR/pelicanconf.py \
                                #--subst-var pelican_plugins
                        make CONFFILE=$TMPDIR/pelicanconf.py publish
    '';
  });
}
