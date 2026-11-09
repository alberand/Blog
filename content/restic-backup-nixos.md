Title: Restic backups on NixOS to Hetzner Storage Box
Date: 11.09.2025
Modified: 11.09.2025
Status: draft
Tags: pelican, publishing
Keywords: pelican, publishing
Slug: restic-backup-nixos
Author: Andrey Albershtein
Summary: NixOS setup to backup files to Hetzner storage box with Restic
Lang: en

Hetzner has pretty cheap storage boxes, at my local taxes it costs me 4.25 euro
per month for a 1T of space (and it's trully 1T not like with HDD ~85% of the
volume). In this post I will describe on how to use `restic` to make automatic
encrypted backups of your photos/documents to storage box.

Previously, I also used borg backup but honestly ergonomics doesn't seem to be
that good. Restoring files is pretty painful even for my level of cli-fu.

[Give me full storage-box.nix][1]

# Setup Hetzner storage box

create storage box
create ssh key
add ssh key

# Basic restic setup

create storage-box.de

# Preparing secrets (ssh key and password)

agenix

# Tips and tricks

## Removing repository

There's no way to tell `restic` to remove repository, to do that manually:

```shell
➜  ssh hetzner
+------------------------------------------------------------------+
| Welcome to your Storage Box.                                     |
|                                                                  |
| Please note that this is only a restricted shell environment and |
| therefore some shell features like pipes and redirects are not   |
| supported.                                                       |
+------------------------------------------------------------------+
u486969 /home > ls
backup  tmp
u486969 /home > rm -r backup
u486969 /home > ls
tmp
u486969 /home > exit
Connection to u486969.your-storagebox.de closed.
```

The `sftp`'s rmdir command doesn't seem to be able recursively remove non-empty
directories. `lftp` doesn't use `~/.ssh/config` host definition which means I
can not do `lftp sftp:hetzner`. So, hail to the SSH!

## Is repository actually encrypted?

Now, how do we do sanity check that there's is no decrypted files on the storage
box. Pretty easy actually, with `ssh` again.

```shell
➜  ssh hetzner
+------------------------------------------------------------------+
| Welcome to your Storage Box.                                     |
|                                                                  |
| Please note that this is only a restricted shell environment and |
| therefore some shell features like pipes and redirects are not   |
| supported.                                                       |
+------------------------------------------------------------------+
u486969 /home > tree backup
backup
├── config
├── data
│   ├── 00
│   ├── 01
│   ├── ...
│   ├── 21
│   │   └── 21f3a6680614e1c083c807ec9562d28e50861f57387ccb61cdeaf932453cc266
│   ├── 22
│   ├── ...
│   ├── fc
│   ├── fd
│   │   └── fde49fccf4612e5c8e72122f86fd0d5864af07d0dcdeb7c1e35ab06ab46e588e
│   ├── fe
│   └── ff
├── index
│   └── 2837b3bbca9ff666d4c177d4a026987f69787c6f781ed353b8a6ff43a1a1f4bf
├── keys
│   └── a08ad0f594573296c9b9431c3a6923a6fc893f81eeca132e66e2959f900fdd18
├── locks
└── snapshots
    └── 8206225325167264a76b3bc3134009d38a20ecc6ec3851b4f379ef57ec7a5c4d

262 directories, 6 files
u486969 /home > cat backup/data/fd/fde49fccf4612e5c8e72122f86fd0d5864af07d0dcdeb7c1e35ab06ab46e588e
...byte soup...
u486969 /home > exit
Connection to u486969.your-storagebox.de closed.
```

None of the files above, except `keys/a08ad0f...`, contains anything resembling
my `backup/foo` file. I haven't dug into how restic encrypts files or if it's
strong enough though. At least, on github I don't see any major encryption
issues.

Another question is that key is stored in the repository itself I suppose, the
only key is therefore my password which should be strong enough. It would be
really nice to find a way to use my SSH or GPG key.

## How to manage backup directories?

I have `/media/backup` to where I put anything important enough.
Elsewhere on the system I have a `photos` store and `immich` directory, also I
have a `container-state/var/lib` directory with runtime files for my containers.
All of this I want to backup.

The straightforward way is to list these directories in restic's `path = []`
option, but I'm not sure about restoring files (will it create files in place?
if so it won't be able to set the owner to root:root e.g.) and if restic wants
to write anything to these backup locations.

So far, I bind-mount `photos` store to the `/media/backup` directory with
read-only filesystem. This way I get backups of my photos while being sure that
restic won't corrupt or remove any of my files. I need to do more research here
though.

[1]: storage-box.nix
