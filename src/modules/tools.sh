#!/bin/sh

shinclude "project.sh"

array()
{
  local index=$1; shift
  local string="$@"

  if [ $index = -1 ]; then echo "${string}" | cut -d " " -f 1-$MAX_PACKAGES; return 0; fi

  local i=0
  for array in $(array -1 "${string}"); do
    if [ $i -eq $index ]; then echo "${array}"; return 0; fi
    i=$((i+1))
  done

  return 1
}

get_default_package()
{
  if [ -z $2 ]; then
    local DEFAULT_PACKAGE_ARRAY="$1"
    for package in $(array -1 "${DEFAULT_PACKAGE_ARRAY}"); do
      if which $package >/dev/null 2>&1; then echo $package; return 0; fi
    done
  else
    echo $2
    return 0
  fi

  return 1
}

get_package_version()
{
  local PKGVERSION=$(pacman -Qi $1 | grep Version | cut -d ':' -f 3 | sed 's/ \+//g')

  if [ -z "${PKGVERSION}" ]; then
    PKGVERSION=$(pacman -Qi $1 | grep Version | cut -d ':' -f 2 | sed 's/ \+//g')
    if [ -z "${PKGVERSION}" ]; then printf "NULL"; return 1; fi
  fi

  printf "${PKGVERSION}"
  return 0
}

