Pacbuilder
==========

A Pacman package builder.
It works as cloning the package source and compiling,
then installing and storing the generated package into Pacman `pkg` folder.

Installation
------------

Copy `src/pacbuilder` to the local binary folder:
```shell
su -c "cp src/pacbuilder /usr/local/bin"
```

Copy `pacbuiler.conf` and `pacbuilder.d` to `/etc` folder:
```shell
su -c "cp -r assets/* /etc"
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

