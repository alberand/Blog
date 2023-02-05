Title: Development setup for Linux Kernel on NixOS
Date: 01.02.2023
Modified: 01.02.2023
Status: draft
Tags: kernel, vm, qemu, nixos
Keywords: pelican, publishing
Slug: nixos-linux-kernel-vm
Author: Andrey Albershtein
Summary: Development setup for Linux kernel on NixOS
Lang: en

NixOS is quite flexible in creating VM. Basically, you can write nix
configuration for a system and build it as VM with a command. As Nix allows to
do anything with the system you can easily add any packages, systemd services,
disks, files etc. 

There are a few disadvantages, however, which could be worked out by a few
hacks. For example, as Nix is always tries to do a clean build it will recompile
your kernel everytime you change it. This is super inconvenient even for a
minimal configuration. However, there is two ways to work around this.

[Download vm.nix][1]

### Full configuration


To compile:

	$ nix-build '<nixpkgs/nixos>' -A vm --arg configuration ./vm.nix

To run:

	$ ./result/bin/run-nixos-vm

[TOC]

### Building VM step by step

#### The simplest NixOS VM

I assume that you are doing this on NixOS or have Nix store setted up on your
system. First of all, create a directory and a simple vm.nix with following
content:

	{ pkgs, ... }:
	{
		imports = [ 
			<nixpkgs/nixos/modules/profiles/qemu-guest.nix>
		];

		# Root with empty password
		users.extraUsers.root.password = "";
		users.mutableUsers = false;

		system.stateVersion = "22.11";
	}

I also suggest to `git init .` to not loose any progress. That's actually enough
to get a working VM. Compile it as follows:

	$ nix-build '<nixpkgs/nixos>' -A vm --arg configuration ./vm.nix

The command above will take quite some time, especially compiling kernel, by
then it should create a `./result` directory. To run a VM use:

	$ ./result/bin/run-nixos-vm

To exit from the VM type `poweroff` command or `CTRL + A` followed by `CTRL + X`
to kill Qemu. I recommend to use `poweroff` as disk image can get corrupted and
your guest system won't boot.

#### Setting up the system

From now on we will configure our VM. The configuration in `vm.nix` is
configuration of the guest system. It can contains some host configuration
though.

Let's add some packages to the VM. This as easy as adding following lines:

	environment.systemPackages = with pkgs; [
		htop
		vim
	];

Now we also need to configure boot options. I don't have much there only the
necessary:

	boot = {
		# Kernel output to console
		kernelParams = ["console=ttyS0,115200n8" "console=ttyS0"];
		# This is happens before systemd
		postBootCommands = ''
			echo 'Not much to do before systemd :)' > /dev/kmsg
		'';
	}

Also important thing is to set our architecture, this is probably could be used
for cross-compilation but I haven't tried that:

	nixpkgs.localSystem.system = "x86_64-linux";

#### References
* [Download vm.nix][1]

[1]:
