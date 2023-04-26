Title: Linux Kernel VM in NixOS
Date: 26.04.2023
Modified: 26.04.2023
Status: published
Tags: kernel, vm, qemu, nixos
Keywords: nixos, vm
Slug: nixos-linux-kernel-vm
Author: Andrey Albershtein
Summary: Development setup for Linux kernel on NixOS
Lang: en

NixOS is quite flexible when it comes to creating VM. I haven't seen such an
easy tool to create images. Basically, you define your system with nix
configuration and then build it with a command. Nix already provides thousands
of packages, all of which you can use in your VM.

There are a few disadvantages though. For example, as Nix is always tries to
build a clean system you will recompiling packages on any change. This is super
inconvenient even for a minimal configuration. But there's definitely a way
around it.

[TOC]

# Full configuration

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
xfstests-overlay = (final: prev: {
	xfstests = prev.xfstests.overrideAttrs (prev: {
		version = "git";
		src = fetchGit /home/alberand/xfstests-dev;
	});
});

# Custom remote xfstests
xfstests-overlay-remote = (final: prev: {
	xfstests = prev.xfstests.overrideAttrs (prev: {
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
		# or pin the version
		kernelPackages = pkgs.linuxKernel.packagesFor pkgs.linuxKernel.kernels.linux_6_0;
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

## The simplest VM

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

I also suggest to `git init .` to not lose any progress. That's actually enough
to get a working VM. Compile it as follows:

```console
                              what
                               to
           path to package    build     argument for build
           vvvvvvvvvvvvvvv     vv       vvvvvvvvvvvvvvvvvvvvvv

nix-build '<nixpkgs/nixos>' -A vm --arg configuration ./vm.nix
```

The command above will take quite some time, especially compiling the kernel.
Eventually `nix-build` creates a `./result` directory. The directory contains
shell script to run VM:

```console
./result/bin/run-nixos-vm
qemu goes brrrrr....
```

To exit from the VM type `poweroff` command or `CTRL + A` followed by `X`
to kill Qemu. I recommend to use `poweroff` as disk image can get corrupted and
your guest system won't boot. Fix it by removing the `nixos.qcow2` image in the
current directory and running VM again.

# Adding package to VM

This is as easy as:

```nix
environment.systemPackages = with pkgs; [
  htop
  util-linux
  vim
  tmux
];
```

Much much easier than using Buildroot or any other tool. The system will have
all necessary packages and will not be bloated as full-blown linux distribution.

Adding overlay on top, to build with your local changes and the process becomes
amazingly easy to get a VM with custom environment. To add overlay:

```nix
let
  # Let's use local source for this package
  xfstests-overlay = (final: prev: {
    xfstests = prev.xfstests.overrideAttrs (prev: {
      version = "git";
      src = /home/alberand/Projects/xfstests-dev;
    });
  });
in {

...

nixpkgs.overlays = [
  xfstests-overlay-remote
];
```

## Customize packages/derivations

In Nix derivation is a package and overlay can be used to change build inputs of
that package. With overlay you can change sources, version, metadata, build
flags, append commands to build scripts etc.

In the following example the sources of the `xfstests` derivation points to
local repository. The `xfstests` derivation is already defined in NixOS packages
store. We don't need to define how to build sources or install them. Check out
[all the parameters][4] set by this derivation.

```nix
# Custom local xfstests
xfstests-overlay = (final: prev: {
  xfstests = prev.xfstests.overrideAttrs (prev: {
    version = "git";
    src = fetchGit /home/alberand/xfstests-dev;
  });
});
```

The `prev` keyword is like input for our overlay. In this case `prev` points
to `pkgs`. The `final` keyword is like output for our overlay - the state of the
`pkgs` after modifications. In this example output is not used directly.

This overlay takes `xfstests` derivation from the inputs and replaces `version`
and `src` parameters of the derivation. When derivation is build new parameters
will be used. The version can be exact `major.minor` or just `git` for not tagged
git tree. The `nix-build` will tell you exact version if you don't know what to
specify. There's many [available fetchers][3] to get sources.

If you use local sources somewhere in the flake you would probably need to
specify `--impure` keyword. This will tell nix to not to be that strict with
version of the sources.

# Custom Kernel and .config

Linux Kernel is provided as derivation and has many helpful derivations already
in store. To build kernel from your local source tree with local `.config`
define following package in the `let` section:

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

VM script which is created by `nix-build` command can use other pre-compiled
kernel, not built by `nix-build`. To achieve this do the following:

0. Remove package which was defined above and `boot.kernelPackage` setting. Fix
   the version of the kernel on the version of your tree. For example, if you
   are building somewhere v6.2 kernel you should do:
 
        kernelPackages = pkgs.linuxKernel.packagesFor pkgs.linuxKernel.kernels.linux_6_2;
 
    The version should correspond to your kernel as nix will build all modules
    for the version defined in nix configuration.
 
1. Compile Linux kernel as you usually do to get `bzImage`. Don't forget to
   enable all necessary features for QEMU build. See [features][5] which Nix
   expects to be enable.
2. Define hostname for VM and build it with `nix-build`
 
        networking.hostName = "vm";
 
4. Export environment variable with path to your kernel and run the VM:
 
         $ export NIXPKGS_QEMU_KERNEL_vm=/path/to/arch/x86/boot/bzImage
         $ ./result/bin/run-vm-vm
 
    The name is `NIXPKGS_QEMU_KERNEL_<networking.hostName>`

I've tried to use CCache with Nix to make its kernel build faster, but that
doesn't seem to work yet. Note that it highly depend on your needs, the modules
can be loaded afterwords when VM already booted. I was looking for a way to
quickly modify the kernel and fire up the VM with testsuite.

# Network and SSH

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

If you are not on NixOS, try following my guide on [setting up host network with
QEMU][6].

# USB and Disks in VM

## Disks and partitions

To share partition with VM add an option to Qemu:

```nix
virtualisation.qemu.options = [
  "-hdc /dev/sda4"
  "-hdd /dev/sda5"
];
```

Or if you need just a dummy space you can add pre-allocated disk image or ask
Nix to create an empty partitions:

```nix
# Nix will create 2 virtual disks
virtualisation.emptyDiskImages = [ 8192 4096 ]; # Create 2 virtual disk with 8G and 4G

# Append images as partitions to VM
virtualisation.qemu.options.drives = [
  { name = "vdc"; file = "${toString ./test.img}"; }
  { name = "vdb"; file = "${toString ./scratch.img}"; }
];
```

## USB devices

To pass a USB device to VM there's three things need to be done:

- Find out device Bus, Port, Vendor ID, and Product ID
- Configure permission to the USB device
- Add configuration to QEMU

**Device BUS and PORT**. we need to find out metadata of the device to identify
it. This can be done with `lsusb` utility. Before connecting your device run
`lsusb`, then connect the device and run it again. Compare to list to find out
what's new. The name of the device could also give a hint (like manufacturer
name or that it is keyboard). Save device Bus, Port, Vendor ID, and Product ID:

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

**Permissions**. To configure permissions since only root has access to USB
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

**QEMU Configuration**. Add one of the following line with changed parameters to
`virtualisation.qemu.options`:

```nix
"-usb -device usb-host,hostbus=2,hostport=4"
# or
"-usb -device usb-host,vendorid=0x8564,productid=0x1000"
```

Boot your VM and check that device is there with `lsusb`, it should have same
vendor and product IDs.

# Create a bootable ISO

Time to deploy VM to cloud or other machine. This is as easy as:

```shell
$ nix-shell -p nixos-generators --run "nixos-generate --format iso \
    --configuration ./vm.nix -o result"
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

The `nixos-generators` packages have many output formats. You can create AWS
images, docker containers, iso, google compute cloud images etc. Note, however,
that not every configuration would work for every output format. For example, if
you define that the image is VM guest (with imports and virtualisation. params)
it won't probably boot on bare metal without manual fixes.

# Tips & tricks to configure the VM

## Run script after boot

Example of systemd service started on boot. You can run some tests with it and
then call shutdown in `postStop`.

```nix
systemd.services. = {
  enable = true;
  serviceConfig = {
    Type = "oneshot";
    StandardOutput = "tty";
    StandardError = "tty";
    User = "root";
    Group = "root";
    WorkingDirectory = "/root";
  };
  after = [ "network.target" "network-online.target" "local-fs.target" ];
  wants = [ "network.target" "network-online.target" "local-fs.target" ];
  wantedBy = [ "multi-user.target" ];
  postStop = ''
    echo "Bye bye"
  '';
  script = ''
    echo "Hello I do work"

    # Beep beep... Human... back to work
    echo -ne '\007'
  '';
};
```

## Environment variables

To define environment variable use following expression:

```nix
environment.variables.NAME = "thisisname";
```

# My setup

I was trying to create a VM which I start with one command, the VM takes kernel
from the current working directory and runs `xfstests` against it.

Then, I decided to write a script to add more features. Now in my working
directory I have `vmtest` command. This commands takes configuration from
`.vmtest` in the current dir.

The configuration contains path to kernel I want to run, list of modules to
load, suite of `xfstests` to run, and QEMU options such as disk partitions. This
will probably grow further as I will need to also will need to change versions
of xfstests and other packages. You can find my [project here][7].

# References
* [Download vm.nix][1]
* [QEMU network on Linux][6]
* [My setup - nix-kernel-vm][7]
* [UDEV rules][2]
* [NixOS fetchers (download sources from anywhere][3]

[1]: https://www.google.com/
[2]: https://wiki.archlinux.org/title/udev
[3]: https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-fetchers
[4]: https://github.com/NixOS/nixpkgs/blob/e506555f21b3a624e3c7af6c26d1467464107f7e/pkgs/tools/misc/xfstests/default.nix
[5]: https://github.com/NixOS/nixpkgs/blob/23968f4c5dba6a59ec7b54fe2dcaebaccefb8bfe/nixos/modules/virtualisation/qemu-vm.nix#L1158-L1176
[6]: https://alberand.com/host-only-networking-set-up-for-qemu-hypervisor.html
[7]: https://github.com/alberand/nix-kernel-vm
