{ self, nixpkgs, pkgs ? import nixpkgs {}, ... }:
let

  #pelican-liquid-tags = pkgs.fetchFromGitHub {
  #  owner = "pelican-plugins";
  #  repo = "liquid-tags";
  #  rev = "a7eeee78ad47952457dcee54827798c5099b87ed";
  #  sha256 = "sha256-nkKpor6OSkiUQppTy8AAURqLdAKAl8+7JVeywXdphds=";
  #};

  #pelican-render-math = pkgs.fetchFromGitHub {
  #  owner = "pelican-plugins";
  #  repo = "render-math";
  #  rev = "f3749b7368d1c889d93f849fea5b500121834810";
  #  sha256 = "sha256-nkKpor6OSkiUQppTy8AAURqLdAKAl8+7JVeywXdphds=";
  #};

  #pelican_plugins = pkgs.linkFarm "pelican_plugins" [
  #        { name = "liquid_tags"; path = pelican-liquid-tags; }
  #        { name = "render_math"; path = pelican-render-math; }
  #];

#	pelican-liquid-tags = (pkgs.python3Packages.buildPythonPackage rec {
#		name = "liquid_tags";
#		src = pkgs.fetchFromGitHub {
#			owner = "pelican-plugins";
#			repo = "liquid-tags";
#			rev = "a7eeee78ad47952457dcee54827798c5099b87ed";
#			sha256 = "sha256-nkKpor6OSkiUQppTy8AAURqLdAKAl8+7JVeywXdphds=";
#		};
#		doCheck = false;
#		propagatedBuildInputs = with pkgs.python3Packages; [
#			pelican 
#			typogrify 
#		];
#	});
#
#	pelican-render-math = pkgs.python3Packages.buildPythonPackage rec {
#		name = "render_math";
#		src = pkgs.fetchFromGitHub {
#			owner = "pelican-plugins";
#			repo = "render-math";
#			rev = "f3749b7368d1c889d93f849fea5b500121834810";
#			sha256 = "sha256-nkKpor6OSkiUQppTy8AAURqLdAKAl8+7JVeywXdphds=";
#		};
#		doCheck = false;
#		propagatedBuildInputs = with pkgs.python3Packages; [
#			pelican
#			typogrify
#		];
#	};
#
#	python-with-my-packages = pkgs.python3.withPackages(ps: with ps; [
#		(pelican-liquid-tags ps)
#		(pelican-render-math ps)
#	]);

  #pelican_plugins = pkgs.linkFarm "pelican_plugins" [
	  #{ name = "liquid_tags"; path = pelican-liquid-tags; }
	  #{ name = "render_math"; path = pelican-render-math; }
  #];

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
