Title: SSD cache for RAID HDD setup using XFS
Date: 02.03.2026
Modified: 02.03.2026
Status: draft
Tags: hdd, ssd, realtime, xfs, raid
Keywords: hdd, ssd, realtime, xfs, raid
Slug: raid-hdd-and-ssd-cache
Author: Andrey Albershtein
Summary: Using SSD for mirrored HDD setup with XFS filesystem
Lang: en

In this post I will describe my setup on how to use SSD for two mirrored HDDs
with XFS's realtime device feature. I use it for my movies storage server with
Jellyfin.

XFS's realtime device is feature which allows XFS to put file metadata (inodes)
onto one device (fast SSD) and data on other device (slower HDD RAID
configuration). The realtimeness of the HDD gives constant lookup jitter of a
file data, which is good for streaming movies.


This setup has a few advantages:
- We can put time sensitive data onto fast SSD and huge data heavy files onto
  HDD.
- All our metadata is on SSD. Overall file lookup has SSD speed. We can also
  apply one little optimization to make it work for small files.
- The realtime device has lower disk space tracking delays. We will have close
  to contant delay for looking up data on disk. This is good for media servers
  such as Jellyfin. The realtime device is not actually any faster, this setup
  reduces latency of the space lookup.

I'm using NixOS, so this post is mostly about Nixos setup, but this approach
could be replicated on any system.

# Software RAID

Skip this section if you don't need software RAID for HDD.

I have two 2T disks (1.8T actually). I will use this storage for my most
important movies and some photos. To make it safe I will decided to got with
mirrored RAID setup.

First thing, is to install mdadm tool onto your system.

```nix
environment.systemPackages = with pkgs; [
    mdadm
];
```

Then create RAID on two partitions:

```shell
sudo mdadm \
    --create \
    --verbose \
    --level=1 \
    --raid-devices=2 \
    /dev/md0 \
    /dev/sdb1 \
    --write-mostly /dev/sdd1
```

To create partition on an empty disk you can use `sudo fdisk /dev/sdd`, then `n`,
enter... enter... enter... then `w`. To remove any existing partition use `d`
and then number of a partition.

`/dev/sdb1` and `/dev/sdd1` are whole disk partitions. The `--write-mostly` flag
is not needed if you have two identical disks. In my case I have one HDD twice
as fast for reading compared to the second one `/dev/sdd1`. Making slow drive
`/dev/sdd1` "write-mostly" tells RAID to read mostly from the second disk. This
way reading would be faster. However, for drives with similar characteristics
this is probably counter-efficient as software RAID have built-in optimizations
for reading.

Then, when disks are ready add this to your `configuration.nix` to import this
RAID disk.

```nix
swraid = {
  enable = true;
  mdadmConf = ''
    PROGRAM ${pkgs.coreutils}/bin/true
    ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 UUID=e1a6ff50:7594b005:4442e9ab:9d5c5251
  '';
};
```

To find out this `ARRAY` line use the following command:

```shell
➜  sudo mdadm --detail --scan --verbose /dev/md0
ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 UUID=e1a6ff50:7594b005:4442e9ab:9d5c5251
   devices=/dev/sdb1,/dev/sdd1
```

Next, don't forget to add necessary kernel modules for software RAID:

```nix
boot.initrd.availableKernelModules = [
  "md_mod"
  "raid1"
];
```

# SSD metadata device

```shell
sudo mkfs.xfs \
    -r rtdev=/dev/md0 \
    -r extsize=1M \
    -m reflink=0 \
    -i size=2048 \
    -f /dev/sda
```

```nix
fileSystems."/bigdata" = {
  device = "/dev/disk/by-uuid/532ae613-9f90-4edc-a2d5-22e5a03adac9";
  fsType = "xfs";
  options = [
    "rtdev=/dev/md0"
    "nofail"
  ];
};
```

# Performance measurement

How?

# Huge risk

There's huge risk that if SSD dies you lose all your data. Even though data is
on RAID HDD mirror, it just a bunch of random blocks. I suppose some intelligent
scanner would be able to restore those files.
