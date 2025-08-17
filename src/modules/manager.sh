#!/bin/sh

source /etc/pacbuilder.d/modules/project.sh

build_packages()
{
  clone_package "$1" $2
  if [ $? -eq 0 ]; then
    build_package "$1"
    if [ $? -eq 0 ]; then
      install_package "$1"
      return 0
    fi
  fi

  printf "%b::%b%b %s %s%b\n" \
    "\033[1;31m" "\033[0m"  \
    "\033[1m" "Could not build the package." "${BUILD_BLAME}" "\033[0m"

  return 1
}

clean_packages()
{
  list_clone_directory $1 1
  if [ $? -eq 0 ]; then
    clean_repository $1
  fi
  return 0
}

edit_packages()
{
  clone_package $1 0 1
  if [ $? -ne 1 ]; then
    build_package $1
    if [ $? -eq 0 ]; then
      install_package $1
    fi
  fi
  return 0
}

list_packages()
{
  list_clone_directory $1
  if [ $? -ne 0 ]; then
    printf "\033[1;31m::\033[0m \033[1mERROR: $1 package not found in clone directory.\n"
    return 1
  fi
  return 0
}

upgrade_packages()
{
  list_clone_directory "$1" 1
  if [ $? -eq 0 ]; then
    clean_repository "$1"
    build_packages "$1" 1
  fi
}

