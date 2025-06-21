Pacbuilder
==========

A Pacman package builder.
It works as cloning the package source and compiling,
then installing and storing the generated package into Pacman `pkg` folder.

Installation
------------

Move `src/pacbuilder` to the local binary folder:
```shell
su -c "cp src/pacbuilder /usr/local/bin"
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

