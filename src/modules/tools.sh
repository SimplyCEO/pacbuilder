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

# $(vercmp 1.0.1 ">" 0.0.1) = 0
# $(vercmp 0.0.1 ">" 1.0.1) = 1
vercmp()
{
  local dest_ver="$1"
  local condition="$2"
  local src_ver="$3"

  local dest_v_major=$(echo "${dest_ver}" | cut -d '.' -f 1)
  if [ -z $dest_v_major ]; then return -1; fi
  local src_v_major=$(echo "${src_ver}" | cut -d '.' -f 1)
  if [ -z $src_v_major ]; then return -1; fi

  local dest_v_minor=$(echo "${dest_ver}" | cut -d '.' -f 2)
  local dest_v_patch=$(echo "${dest_ver}" | cut -d '.' -f 3)
  local dest_v_extra=$(echo "${dest_ver}" | cut -d '.' -f 4)

  local src_v_minor=$(echo "${src_ver}" | cut -d '.' -f 2)
  local src_v_patch=$(echo "${src_ver}" | cut -d '.' -f 3)
  local src_v_extra=$(echo "${src_ver}" | cut -d '.' -f 4)

  local dest_v_def=$((dest_v_extra+(dest_v_patch*10000)+(dest_v_minor*1000000)+(dest_v_major*1000000000)))
  local src_v_def=$((src_v_extra+(src_v_patch*10000)+(src_v_minor*1000000)+(src_v_major*1000000000)))
  case $condition in
    "==") if [ ! $dest_v_def -eq $src_v_def ]; then return 1; fi ;;
    "!=") if [ ! $dest_v_def -ne $src_v_def ]; then return 1; fi ;;
    "<") if [ ! $dest_v_def -lt $src_v_def ]; then return 1; fi ;;
    "<=") if [ ! $dest_v_def -le $src_v_def ]; then return 1; fi ;;
    ">") if [ ! $dest_v_def -gt $src_v_def ]; then return 1; fi ;;
    ">=") if [ ! $dest_v_def -ge $src_v_def ]; then return 1; fi ;;
  esac

  return 0
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

