{
	description = "A very basic flake";

	outputs = { self, nixpkgs }: let
		blog = (import ./blog.nix { inherit nixpkgs; });
	in {

		packages.x86-64-linux.blog = blog.local-blog;
		packages.x86-64-linux.publish = blog.blog;

		packages.x86_64-linux.default = self.packages.x86_64-linux.blog;

		apps = {
			default = {
				type = "app";
				program = "${self.packages.x86_64.default}/bin/go-hello";
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
	};
}
