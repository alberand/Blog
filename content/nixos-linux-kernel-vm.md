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

{% include_code nixos-vm/vm.nix lang:c :hideall: %}

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

To exit from the VM type `poweroff` command or `CTRL + A` followed by `X`
to kill Qemu. I recommend to use `poweroff` as disk image can get corrupted and
your guest system won't boot.

#### Tips & tricks to configure the VM

From now on we will configure our VM. The configuration in `vm.nix` is
configuration of the guest system. It can contains some host configuration
though.

Let's add some packages to the VM. This as easy as adding following lines:

	environment.systemPackages = with pkgs; [
		htop
		vim
	];

Example of systemd service started on boot. You can do some setup in there.

  # Do something after systemd started
  systemd.services.foo = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo 'This service runs right near login' > /dev/kmsg
    '';
  };

Environment variable. To define environment variable use following expression:

	environment.variables.NAME = "thisisname";

Qemu options, shared directories, shared disks could be added in
`virtualization`. For this you will also need to import
`/virtualisation/qemu-vm.nix`.

```
virtualisation = {
    diskSize = 20000; # MB
    memorySize = 4096; # MB
    cores = 4;
    writableStoreUseTmpfs = false;
    useDefaultFilesystems = true;
    # Run qemu in the terminal not in Qemu GUI
    graphics = false;
    # Create 2 virtual disk with 8G and 4G. Similar to the `drives` section
    # below by no need to create them beforehand
    #emptyDiskImages = [ 8192 4096 ];

    qemu = {
      options = [
        # I want to try a kernel which I compiled somewhere
        #"-kernel /home/user/my-linux/arch/x86/boot/bzImage"
        #"-kernel /home/alberand/my-linux/arch/x86/boot/bzImage"
        # OR
        # You can set env. variable not to change configuration everytime:
        #   export NIXPKGS_QEMU_KERNEL_fstests_vm=/path/to/arch/x86/boot/bzImage
        # The name is NIXPKGS_QEMU_KERNEL_<networking.hostName>

        # Append hardware partitions/disk to VM
        "-hdc /dev/sda4"
        "-hdd /dev/sda5"
      ];
      # Append images as partition to VM. Don't forget to create them with dd
      drives = [
        { name = "vdc"; file = "${toString ./test.img}"; }
        { name = "vdb"; file = "${toString ./scratch.img}"; }
      ];
    };

    sharedDirectories = {
      fstests = { 
        source = "/home/alberand/Projects/xfstests-dev";
        target = "/root/xfstests"; 
      };
    };
};
``

### Custom Kernel

### Adding my local packages

### Creating ISO

#### References
* [Download vm.nix][1]

[1]:
