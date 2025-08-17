#!/bin/sh

source /etc/pacbuilder.d/modules/project.sh

fhelp()
{
  local EXTRA_FLAG=$1

  if [ $(strncmp "${EXTRA_FLAG}" "-h" 2) = 0 ] || [ $(strncmp "${EXTRA_FLAG}" "--help" 6) = 0 ]; then
    printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"                                   \
      "usage:  ${PROJECT_NAME} {-B --build} [options] [package(s)]"                 \
      "options:"                                                                    \
      "  -u, --upgrade        clean and upgrade the contents of each package."      \
      "      --clean          clean build contents of each given package."            \
      "      --list           list the existing packages from the build directory"  \
      "                       or their contents, if provided name."                 \
      "      --edit           edit PKGBUILD before compiling."                      \
      "                       the modification will be stored as a patch file."     \
      "      --purge          clean source files within the package directory."  \
      "      --skippgpcheck   skip PGP key signature checking: not recommended."
  else
    pacman --help | head -n 11 | sed "s/pacman/${PROJECT_NAME}/g"
    printf "    ${PROJECT_NAME} {-B --build}    [options] [package(s)]\n\n"
    pacman --help | tail -n 1 | sed "s/pacman/${PROJECT_NAME}/g"
  fi

  return 0
}

fversion()
{
  printf "%s\n%s\n%s\n%s\n%s\n%s\n"                                                         \
    "  .--.                  Pacbuilder v${PROJECT_VERSION}"                                \
    " / _.-' .-.  .-.  .-.   Copyright (C) 2025 SimplyCEO <simplyceo.developer@gmail.com>"  \
    " \\  '-. '-'  '-'  '-'   Repository: https://github.com/SimplyCEO/pacbuilder"          \
    "  '--'"                                                                                \
    "                        This application may be freely redistributed under"            \
    "                        the terms of the Open Software License 3.0."

  return 0
}

