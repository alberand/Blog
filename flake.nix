{
	description = "A very basic flake";

	inputs = {
		flake-utils.url = "github:numtide/flake-utils";
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, flake-utils }:
	flake-utils.lib.eachDefaultSystem (system: let
		pkgs = nixpkgs.legacyPackages.${system};
		blog = (import ./derivation.nix { inherit self nixpkgs pkgs; });
	in {

		packages.blog = blog.blog-dev;
		packages.publish = blog.blog-pub;

		packages.default = blog.blog-dev;

		apps = {
			default = {
				type = "app";
				program = "${self.packages.${system}.default}/serve";
			};
		};

		devShells = {
			default = nixpkgs.mkShell {
					buildInputs = with nixpkgs; [
						(nixpkgs.python3.withPackages
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
