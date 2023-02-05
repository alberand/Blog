{pkgs, lib, buildPythonPackage, fetchPypi}:

buildPythonPackage rec {
  name = "render_math";
  #version = "1.0.4";

  nativeCheckInputs = with pkgs.python3Packages; [ pelican typogrify ];
  buildInputs = with pkgs.python3Packages; [ pelican typogrify ];
		src = pkgs.fetchFromGitHub {
			owner = "pelican-plugins";
			repo = "render-math";
			rev = "f3749b7368d1c889d93f849fea5b500121834810";
			sha256 = "sha256-nkKpor6OSkiUQppTy8AAURqLdAKAl8+7JVeywXdphds=";
		};
		doCheck = false;
}
