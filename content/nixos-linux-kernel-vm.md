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

[TOC]

### Full configuration

To compile:

```console
nix-build '<nixpkgs/nixos>' -A vm --arg configuration ./vm.nix
```

To run:

```console
./result/bin/run-nixos-vm
```

Configuration:

```nix
{ config, modulesPath, pkgs, lib, ... }: let

# Custom local xfstests
xfstests-overlay = (self: super: {
	xfstests = super.xfstests.overrideAttrs (prev: {
		version = "git";
		src = fetchGit /home/alberand/xfstests-dev;
	});
});

# Custom remote xfstests
xfstests-overlay-remote = (self: super: {
	xfstests = super.xfstests.overrideAttrs (prev: {
		version = "git";
		src = pkgs.fetchFromGitHub {
			owner = "alberand";
			repo = "xfstests";
			rev = "6e6fb1c6cc619afb790678f9530ff5c06bb8f24c";
			sha256 = "OjkO7wTqToY1/U8GX92szSe7mAIL+61NoZoBiU/pjPE=";
		};
	});
});

kernel-custom = pkgs.linuxKernel.customPackage { 
	# Note that nix uses this version to install relevant tools (e.g. flex).
	# You can specify 'git' not to change it every time you change the verions
	# but I haven't got it working properly. Nix will tell you which version
	# you should specify if you don't know.
	version = "6.2.0-rc2";
	configfile = /home/alberand/kernel/.config;
	src = fetchGit /home/alberand/kernel;
};

in
{
	imports = [ 
		(modulesPath + "/profiles/qemu-guest.nix") 
		(modulesPath + "/virtualisation/qemu-vm.nix")
	];

	boot = {
		kernelParams = ["console=ttyS0,115200n8" "console=ttyS0"];
		consoleLogLevel = lib.mkDefault 7;
		# This is happens before systemd
		postBootCommands = "echo 'Not much to do before systemd :)' > /dev/kmsg";
		crashDump.enable = true;

		# Set my custom kernel
		# kernelPackages = kernel-custom;
	};

	# Auto-login with empty password
	users.extraUsers.root.initialHashedPassword = "";
	services.getty.autologinUser = lib.mkDefault "root";

	networking.firewall.enable = false;
	networking.hostName = "vm";
	networking.useDHCP = false;
	services.getty.helpLine = ''
		Log in as "root" with an empty password.
		If you are connect via serial console:
		Type CTRL-A X to exit QEMU
	'';

	# Not needed in VM
	documentation.doc.enable = false;
	documentation.man.enable = false;
	documentation.nixos.enable = false;
	documentation.info.enable = false;
	programs.bash.enableCompletion = false;
	programs.command-not-found.enable = false;

	# Do something after systemd started
	systemd.services.foo = {
		serviceConfig.Type = "oneshot";
		wantedBy = [ "multi-user.target" ];
		script = ''
			echo 'This service runs right near login' > /dev/kmsg
		'';
	};

	# Setup envirionment
	environment.variables.TERM = "xterm";

	virtualisation = {
		diskSize = 20000; # MB
		memorySize = 4096; # MB
		cores = 4;
		writableStoreUseTmpfs = false;
		useDefaultFilesystems = true;
		# Run qemu in the terminal not in Qemu GUI (to exit CTRL + A -> X)
		graphics = false;
		# Create 2 virtual disk with 8G and 4G (run 'lsblk' in VM)
		emptyDiskImages = [ 8192 4096 ];

		qemu = {
			options = [
				# I want to try a kernel which I compiled somewhere
				#"-kernel /home/user/my-linux/arch/x86/boot/bzImage"
				#"-kernel /home/alberand/my-linux/arch/x86/boot/bzImage"
				# OR
				# You can set env. variable not to change configuration everytime:
				#   export NIXPKGS_QEMU_KERNEL_vm=/path/to/arch/x86/boot/bzImage
				# The name is NIXPKGS_QEMU_KERNEL_<networking.hostName>
				
				# Append real partitions to VM
				# "-hdc /dev/sda4"
				# "-hdd /dev/sda5"
				
				# better handling of console interface
				"-serial mon:stdio"
			];

			# Append images as partition to VM
			# Don't forget to create images. For example, with:
			#   xfs_io -f -c "falloc 0 10g" test.img
			# OR much slower version:
			#   dd if=/dev/null of=test.img bs=4k count=2450
			drives = [
				#{ name = "vdc"; file = "${toString ./test.img}"; }
				#{ name = "vdb"; file = "${toString ./scratch.img}"; }
			];
		};

		sharedDirectories = {
			# fstests = { 
			#	source = "/home/alberand/Projects/xfstests-dev";
			#	target = "/root/xfstests"; 
			# };
		};
	};

	# Add packages to VM
	environment.systemPackages = with pkgs; [
		htop
			util-linux
			xfstests
			vim
			tmux
			fsverity-utils
			trace-cmd
			perf-tools
			linuxPackages_latest.perf
			openssl
	];


	# Apply overlay on the package (use different src as we replaced 'src = ')
	nixpkgs.overlays = [ 
		xfstests-overlay-remote
	];

	# xfstests related
	users.users.paul = {
		isNormalUser  = true;
		description  = "Test user";
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.11"; # Did you read the comment?
}
```

#### The simplest VM

Create a directory and a simple vm.nix with following content:

```nix
{ pkgs, ... }:
{
	imports = [ 
		<nixpkgs/nixos/modules/profiles/qemu-guest.nix>
		<nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
	];

	# Root with empty password
	users.extraUsers.root.password = "";
	users.mutableUsers = false;

	system.stateVersion = "22.11";
}
```

I also suggest to `git init .` to not loose any progress. That's actually enough
to get a working VM. Compile it as follows:

```console
nix-build '<nixpkgs/nixos>' -A vm --arg configuration ./vm.nix
```

The command above will take quite some time, especially compiling the kernel.
Eventually `nix-build` creates a `./result` directory. The directory contains
shell script to run VM:

```console
./result/bin/run-nixos-vm
```

To exit from the VM type `poweroff` command or `CTRL + A` followed by `X`
to kill Qemu. I recommend to use `poweroff` as disk image can get corrupted and
your guest system won't boot (fix by removing the image and running VM again).

#### Customize packages/derivations

The `let` section above contains a few derivation overlays. In Nix derivation is
a package and overlay is like patch to the package. With overlay you can change
sources, version, metadata, build flags etc.

In the following example the sources of the `xfstests` derivation points to
local repository. The `xfstests` derivation is already defined in NixOS packages
store. We don't need to define how to build and install scripts.

```nix
# Custom local xfstests
xfstests-overlay = (self: super: {
    xfstests = super.xfstests.overrideAttrs (prev: {
        version = "git";
        src = fetchGit /home/alberand/xfstests-dev;
    });
});
```

The `super` keyword is like input for our overlay. In this case `super` points
to `pkgs`. The `self` keyword is like output for our overlay. In this example
output is not used directly. 

This overlay takes `xfstests` derivation from the inputs and replaces `version`
and `src` parameters of the derivation. When derivation is build new parameters
will be used. The version can be exact major.minor or just git for not tagged
git tree.

#### Custom Kernel and .config

Linux Kernel is also provided as derivation and has many helpful derivation
already in store. To build kernel from your local source tree with local
`.config` define following package in the `let` section:

```nix
kernel-custom = pkgs.linuxKernel.customPackage { 
    # Note that nix uses this version to install relevant tools (e.g. flex).
    # You can specify 'git' not to change it every time you change the verions
    # but I haven't got it working properly. Nix will tell you which version
    # you should specify if you don't know.
    version = "6.2.0-rc2";
    configfile = /home/alberand/kernel/.config;
    src = fetchGit /home/alberand/kernel;
};
```

and then set this package as default kernel in the config section:

```nix
boot.kernelPackages = kernel-custom;
```

However, one problem with this setup is that any change to the `.config` or
kernel tree triggers Nix to rebuild the kernel. The rebuild happens because Nix
tries to make a clean build.

VM script which is created by `nix-build` command can use other kernel, not
built by `nix-build`. To achieve this do following:

0. Remove package which was defined above and `boot.kernelPackage` setting
1. Compile linux kernel as you usually do to get `bzImage`
2. Define hostname in your VM:

	```nix
	networking.hostName = "vm";
	```

3. `nix-build` the VM
4. Export environment variable with path to your kernel:

	```nix
	export NIXPKGS_QEMU_KERNEL_vm=/path/to/arch/x86/boot/bzImage
	```

	The name is `NIXPKGS_QEMU_KERNEL_<networking.hostName>`

5. Run the VM `./result/bin/run-vm-vm`

I've tried to use CCache with Nix to make its kernel build faster, but that
doesn't seem to work yet.

#### Network and SSH

Create interface on the host side, assuming you are on NixOS:

```nix
# This goes into your host configuration.nix
networking.interfaces.tap0 = {
	name = "tap0";
	virtual = true;
	virtualType = "tap";
	virtualOwner = "alberand";
};

networking.interfaces.tap0 = {
	ipv4 = {
		addresses = [{
			address = "192.168.10.1";
			prefixLength = 16;
		}];
	};
};
```

Then set IP static address for VM and enable SSH server:

```nix
# This goes into your vm.nix
networking.interfaces.eth1 = {
	ipv4.addresses = [{
		address = "192.168.10.2";
		prefixLength = 24;
	}];
};
services.openssh.enable = true;
```

#### Adding package to VM

This is as easy as:

```nix
environment.systemPackages = with pkgs; [
	htop
	util-linux
	xfstests
	vim
	tmux
	fsverity-utils
];
```

Adding overlay on top to build with your local changes and it becomes amazingly
easy to get a VM with custom environment. To add overlay:

```nix
let
	# Let's use local source for this package
	xfstests-overlay = (self: super: {
		xfstests = super.xfstests.overrideAttrs (super: {
			version = "git";
			src = /home/alberand/Projects/xfstests-dev;
		});
	});
in {
...
<snip>
...

nixpkgs.overlays = [
	xfstests-overlay-remote
];
```

#### Bypassing hardware to VM (USB, HDD)

##### Disks and partitions

To share partition with VM add an option to Qemu:

```nix
virtualisation.qemu.options = [
	"-hdc /dev/sda4"
	"-hdd /dev/sda5"
];
```
Or if you need just a dummy space you can add pre-allocated disk image or ask
Nix to create some empty partitions:

```nix
# Nix will create 2 virtual disks
virtualisation.emptyDiskImages = [ 8192 4096 ]; # Create 2 virtual disk with 8G and 4G

# Append images as partitions to VM
virtualisation.qemu.options.drives = [
	{ name = "vdc"; file = "${toString ./test.img}"; }
	{ name = "vdb"; file = "${toString ./scratch.img}"; }
];
```

##### USB devices

To pass a USB device to VM there's three things need to be done:

- Find out device Bus, Port, Vendor ID, and Product ID
- Configure permission to the USB device
- Add configuration to QEMU

Firstly, we need to find out metadata of the device to identify it. This can be
done with `lsusb` utility. Before connecting your device run `lsusb`, then
connect the device and run it again. Compare to list to find out what's new. The
name of the device could also give a hint (like manufacturer name or that it is
keyboard). Save device Bus, Port, Vendor ID, and Product ID:

```
       bus        port    vend prod
       vvv        vvv     vvvv vvvv

   Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
   Bus 003 Device 124: ID 0424:2514 Microchip Technology, Inc. (formerly SMSC) USB 2.0 Hub
   Bus 003 Device 123: ID 413c:2113 Dell Computer Corp. KB216 Wired Keyboard
   Bus 003 Device 122: ID 03f0:0941 HP, Inc X500 Optical Mouse
   Bus 003 Device 121: ID 1a40:0101 Terminus Technology Inc. Hub
   Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
>> Bus 002 Device 003: ID 8564:1000 Transcend Information, Inc. JetFlash
   Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
   Bus 001 Device 006: ID 1b3f:2002 Generalplus Technology Inc. 808 Camera
   Bus 001 Device 002: ID 8087:0032 Intel Corp. AX210 Bluetooth
   Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

Note that Bus and Device number could change depending on which USB port you
use!

Second step is to configure permissions since only root has access to USB
devices by default. To achieve this we can use `udev`. This utility is
responsible for preparing device for use when hardware is connected - for
example loading kernel driver. We need to create a rule to tell `udev` make our
device accessible for our user. I recommend using `vendorid` and `productid`
attributes to always uniquely identify the device:

```
# 32G flash drive
#
# From lsusb:
# Bus 002 Device 003: ID 8564:1000 Transcend Information, Inc. JetFlash
#
#                                   vvvvvvvvvvvvvvvvvvvvvvvvvv change vvvvvvvvvvvvvvvvvvvvvvvvvv
#                                   vvvv                     vvvv                       vvvvvvvv
SUBSYSTEMS=="usb", ATTR{idVendor}=="8564", ATTR{idProduct}=="1000", MODE="0660", OWNER="alberand"
```

Add this rule to `/etc/udev/rules.d/99-vm.rules` or on NixOS to
`services.udev.extraRules`. Lastly, let's reload the rules so new rule is
applied:

```shell
$ sudo udevadm control --reload-rules && sudo udevadm trigger
$ # Check that owner changed (path could differ!):
$ ls -la /dev/bus/usb/002
total 0
drwxr-xr-x 2 root     root       80 Apr  2 14:36 .
drwxr-xr-x 6 root     root      120 Mar 24 11:55 ..
crw-rw-r-- 1 root     root 189, 128 Apr  2 14:38 001
crw-rw---- 1 alberand root 189, 130 Apr  2 14:39 003
```

For more details on `udev` see [arch wiki][2].

The last step is to add configuration to QEMU. Add one of the following line
with changed parameters to `virtualisation.qemu.options`:

```nix
"-usb -device usb-host,hostbus=2,hostport=4"
# or
"-usb -device usb-host,vendorid=0x8564,productid=0x1000"
```

Boot your VM and check that device is there with `lsusb`, it should have same
vendor and product IDs.

#### Create a bootable ISO

Time to deploy the VM to cloud or other machine. This is as easy as:

```shell
$ nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./vm.nix -o result"
```

Test it with:

```shell
$ nix-shell -p qemu
$ qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-*.iso
```

Flash it to disk:

```shell
                              your disk
                                 vvv
$ dd if=result/iso/*.iso of=/dev/sdX status=progress
$ sync
```

#### Tips & tricks to configure the VM

From now on we will configure our VM. The configuration in `vm.nix` is
configuration of the guest system. It can contains some host configuration
though.

Example of systemd service started on boot. You can do some setup in there.

```nix
# Do something after systemd started
systemd.services.foo = {
	serviceConfig.Type = "oneshot";
	wantedBy = [ "multi-user.target" ];
	script = ''
		echo 'This service runs right near login' > /dev/kmsg
	'';
};
```

Environment variable. To define environment variable use following expression:

	environment.variables.NAME = "thisisname";

Qemu options, shared directories, shared disks could be added in
`virtualization`. For this you will also need to import
`/virtualisation/qemu-vm.nix`.

#### References
* [Download vm.nix][1]

[1]: https://www.google.com/
[2]: https://wiki.archlinux.org/title/udev
