Title: How to restore borg backups?
Date: 06.03.2025
Modified: 06.03.2025
Status: published
Tags: borg, backup, restore backup, borg cli
Keywords: borg, backup, restore backup, borg cli
Slug: how-to-restore-borg
Author: Andrey Albershtein
Summary: I always forget how to restore borg backup. Here are command to do that.
Lang: en

[Borg][1] is pretty good backup solution. I use it with [BorgBase][2] to backup my
database for side projects and minecraft world. As Borg does deduplication your
backups won't grow too much leading to huge invoices. The BorgBase is pretty
good and I can recommend it.

Anyway I always forget how to restore borg backup. Here are command to do that:

List names of all backups:

```shell
borg list --format '{name}{NL}' ssh://xxxxxxxx@xxxxxxxx.repo.borgbase.com/./repo
```

If you want just the latest one add --last.

Find the one you want to restore. They have dates in the name. With BorgBase you
can also find out size change of the backup. `borg` also can do this with
`{size}` but you need to specify which archive you want it to list.

```shell
borg extract --list --progress "ssh://xxxxxxxx@xxxxxxxx.repo.borgbase.com/./repo::nixxy-borgbase-2025-02-21T00:00:05"
```
Downloads full backup. It will take time :)

Test it with `--dry-run`.

When you backup your stuff you probably specified a full path to the files. For
example, I did a backup of `/var/lib/minecraft/My World`. By default borg will
create `./var/lib/minecraft/My World`. To strip these first 3 directories use
`--strip-components 3`.

To restore specific files or directories:

```shell
borg extract /path/to/repository::archive-name path/to/file path/to/directory
```

For extracting only certain file types or using patterns:

```shell
borg extract /path/to/repository::archive-name --pattern '*.jpg'
```

Use `--exclude` to skip certain patterns.

[1]: https://en.wikipedia.org/wiki/Borg_(backup_software)
[2]: https://www.borgbase.com/
