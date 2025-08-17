Pacbuilder
==========

A Pacman package builder/wrapper.
It works as cloning the package source and compiling,
then installing and storing the generated package into Pacman `pkg` folder.

This is not the original project,
since the original has been deprecated and no longer works,
but it works in a unique way.

The main goal is to provide the best solution for building packages,
while acting as a extension for Pacman.

Installation
------------

Copy `src/pacbuilder` to the local binary folder:
```shell
su -c "make install-binary"
```

Copy `pacbuiler.conf` and `pacbuilder.d` to `/etc` folder:
```shell
su -c "make install-configuration install-mirrorlist"
```

Optional: Alias the `pacman` command to `pacbuilder` in the `.$SHELLrc` initialisation file:
```shell
alias pacman=pacbuilder
```

Usage
-----

Pacbuilder use the `-B` or `--build` flags, not found in Pacman page:
```shell
pacbuilder -B <package>
```

Repositories are stored in `/etc/pacbuilder.d/mirrorlist`.

The file is read from top to bottom and it will not add lines that are commented out (#).

AUR cloning is fully supported, even though it is not a tool for it. Use a ideal tool for the job, like `paru`, for AUR package wrapping.

Goals
-----

- Check alias naming for `pacbuilder`, such as `pacman`, and print the help information as the aliased name
- Check upgradable packages and offer a way to build them
- Code refactor
- Log translations
- Must handle versioning checks for the dependencies
- Save the `makedependencies` to unistall under `/var/log/pacbuilder.makedependencies.log` or something, so if the computer is rebooted, it can still remove the `makedependencies` packages
- Translate code to C:
  * Create a way to print out a whole Shell Script as a webscript.
  * Set MACRO for each feature, allowing users to choose and create their own version.
  * Use only `Makefile`, nothing more.
  * Be compatible with TinyCC.
  * No dependency on GNU.
  * Be available for the use with MSYS2.

Licencing
---------

Since this a completely rewritten project, the licence changed to Open Software License 3.0, even though it may not be ideal for most users.

