{pkgs, lib, buildPythonPackage, fetchPypi}:

buildPythonPackage rec {
  name = "liquid_tags";
  #version = "1.0.4";

  nativeCheckInputs = with pkgs.python3Packages; [ pelican typogrify ];
  buildInputs = with pkgs.python3Packages; [ pelican typogrify ];
		src = pkgs.fetchFromGitHub {
			owner = "pelican-plugins";
			repo = "liquid-tags";
			rev = "a7eeee78ad47952457dcee54827798c5099b87ed";
			sha256 = "sha256-nkKpor6OSkiUQppTy8AAURqLdAKAl8+7JVeywXdphds=";
		};

		doCheck = false;
}
