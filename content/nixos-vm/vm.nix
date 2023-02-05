{ pkgs, ... }:
{
	imports = [ 
		<nixpkgs/nixos/modules/profiles/qemu-guest.nix>
	];

	users.extraUsers.root.password = "";
	users.mutableUsers = false;

	environment.systemPackages = with pkgs; [
		htop
		vim
	];

	system.stateVersion = "22.11";
}
