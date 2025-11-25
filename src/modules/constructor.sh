#!/bin/sh

shinclude "project.sh"
shinclude "tools.sh"

BUILD_BLAME=""

list_clone_directory()
{
  local PACKAGE=$1
  local SILENT=$2

  if [ ! -z $SILENT ] && [ $SILENT -eq 1 ]; then
    if [ -z "${PACKAGE}" ] || [ "${PACKAGE}" = "NULL" ]; then
      if [ -d "${REPO_FOLDER}" ]; then return 0; else return 1; fi
    else
      if [ -d "${REPO_FOLDER}/${PACKAGE}" ]; then return 0; else return 1; fi
    fi
  else
    if [ -z "${PACKAGE}" ] || [ "${PACKAGE}" = "NULL" ]; then
      ls "${REPO_FOLDER}"
    else
      ls "${REPO_FOLDER}/${PACKAGE}" 2>/dev/null
    fi
  fi

  return $?
}

fetch_pgp_key()
{
  if [ -d "./keys/pgp" ] && [ ! -z "$(ls ./keys/pgp/*.asc)" ]; then
    printf "%b::%b%b %s%b\n" \
      "\033[1;34m" "\033[0m"  \
      "\033[1m" "Local PGP keys found. Importing..." "\033[0m"
    gpg --quiet --import ./keys/pgp/*.asc
    return 0
  fi

  return 1
}

compare_version()
{
  local PACKAGE="$1"

  makepkg --printsrcinfo > .SRCINFO

  local LOCAL_PACKAGE_VERSION="$(cat .SRCINFO | grep pkgver | cut -d '=' -f 2 | sed 's/ \+//g')-$(cat .SRCINFO | grep pkgrel | cut -d '=' -f 2 | sed 's/ \+//g')"
  local PACKAGE_VERSION=$(get_package_version "${PACKAGE}")

  if [ "${LOCAL_PACKAGE_VERSION}" = "${PACKAGE_VERSION}" ]; then
    return 1
  fi

  return 0
}

install_package()
{
  local PACKAGE=$1
  local iretry=3
  local wcolr="\033[0m"

  if [ ! -z $SU_RETRY ]; then iretry=$SU_RETRY; fi

  cd "${REPO_FOLDER}/${PACKAGE}"
  printf "\033[1;34m::\033[0m (${wcolr}$iretry\033[0m) \033[1mPackage built successfully, installing... "

  while [ $iretry -gt 0 ]; do
    iretry=$((iretry-1))
    case $iretry in
      2) wcolr="\033[33m" ;;
      1) wcolr="\033[31m" ;;
    esac

    su -c "pacman -U *.pkg.tar.* && mv *.pkg.tar.* /var/cache/pacman/pkg"

    if [ $? -eq 0 ]; then return 0
    else
      if [ $iretry -gt 0 ]; then printf "\033[1;34m::\033[0m (${wcolr}$iretry\033[0m) \033[1mPassword is incorrect. Retrying... "; fi
    fi
  done

  return 1
}

build_dependencies()
{
  local MISSING_DEPENDENCIES=""

  local line=1
  while true; do
    local SRCINFO_LINE=$(cat .SRCINFO | head -n $line | tail -n 1)
    if [ -z "${SRCINFO_LINE}" ]; then break; fi

    local SRCINFO_VAR=$(echo "${SRCINFO_LINE}" | grep -w pkgname | cut -d "=" -f 1 | sed "s/ //g" | xargs)
    local SRCINFO_VAL=$(echo "${SRCINFO_LINE}" | grep -w pkgname | cut -d "=" -f 2 | sed "s/ //g" | xargs)

    if [ ! -z "${SRCINFO_VAR}" ] && \
       [ ! -z "${SRCINFO_VAL}" ] && \
       [ "${SRCINFO_VAL}" != "${PACKAGE}" ]; then break; fi
    line=$((line+1))
  done

  if [ $DEPENDENCY_RABBIT_HOLE -le 1 ]; then
    local MAKEDEPENDS=""
    local DEPENDENCIES=""
    local OPTDEPENDS=""

    if [ ! -z $COMPILE_MAKEDEPENDS ] && [ $COMPILE_MAKEDEPENDS -eq 1 ]; then
      MAKEDEPENDS=$(cat .SRCINFO | head -n $line | grep -w makedepends | cut -d "=" -f 2 | sed "s/ //g" | xargs)
    fi
    if [ ! -z $COMPILE_DEPENDENCIES ] && [ $COMPILE_DEPENDENCIES -eq 1 ]; then
      DEPENDENCIES=$(cat .SRCINFO | head -n $line | grep -w depends | cut -d "=" -f 2 | sed "s/ //g" | xargs)
    fi
    if [ ! -z $COMPILE_OPTDEPENDS ] && [ $COMPILE_OPTDEPENDS -eq 1 ]; then
      OPTDEPENDS=$(cat .SRCINFO | head -n $line | grep -w optdepends | cut -d "=" -f 2 | sed "s/ //g" | xargs)
    fi

    local DEPENDS="${MAKEDEPENDS} ${DEPENDENCIES} ${OPTDEPENDS}"
    if [ -z $(echo "${DEPENDS}" | sed "s/ //g") ]; then return 1; fi

    for package in $(array -1 "${DEPENDS}"); do
      if [ $DEPENDENCY_RABBIT_HOLE -gt 1 ] && [ $(pacman -Q | grep -E "^${package}" | cut -d " " -f 1) = "${package}" ]; then continue; fi
      MISSING_DEPENDENCIES="${MISSING_DEPENDENCIES} ${package}"
    done
  fi

  if [ -z $(echo "${MISSING_DEPENDENCIES}" | sed "s/ //g") ]; then return 1; fi
  if [ $DEPENDENCY_RABBIT_HOLE -le 1 ]; then
    printf "\033[1;33m==>\033[0m Building package dependencies: %s...\n" "${MISSING_DEPENDENCIES}"
  else
    printf "==> Missing dependencies: %s. Building...\n" "${MISSING_DEPENDENCIES}"
  fi
  for package in $(array -1 "${MISSING_DEPENDENCIES}"); do
    build_packages "${package}"
  done

  return 0
}

build_package()
{
  local PACKAGE=$1
  cd "${REPO_FOLDER}/${PACKAGE}"

  if [ -z "${PACKAGE_PWD}" ]; then PACKAGE_PWD="$(pwd)"; fi
  if [ $(basename "${PACKAGE_PWD}") = "${PACKAGE}" ]; then cd "${PACKAGE_PWD}"; fi

  if [ $UPGRADE_PACKAGES -eq 1 ]; then
    compare_version "${PACKAGE}"
    if [ $? -eq 1 ]; then
      BUILD_BLAME="Package version is the same as system."
      return 1
    fi
  fi

  DEPENDENCY_RABBIT_HOLE=$((DEPENDENCY_RABBIT_HOLE+1))
  build_dependencies

  if [ $(basename "${PACKAGE_PWD}") = "${PACKAGE}" ]; then cd "${PACKAGE_PWD}"; fi
  for data in $(/bin/ls); do
    if [ "${data}" = "PKGBUILD.patch" ]; then
      patch -N PKGBUILD < PKGBUILD.patch > /dev/null 2>&1
      makepkg -g >> PKGBUILD
    fi
  done

  makepkg -s "${SKIP_PGP_SIGNATURE}"
  if [ $? -ne 0 ]; then
    fetch_pgp_key
    if [ $? -eq 0 ]; then makepkg -s; fi
  fi

  return $?
}

clean_package()
{
  local PACKAGE=$1

  if [ -d "${REPO_FOLDER}/${PACKAGE}" ]; then
    if [ $PURGE_PACKAGES -eq 1 ]; then
      printf "\033[1;34m::\033[0m \033[1mPurging \'${PACKAGE}\' package source tree...\033[0m\n"
      rm -rf "${REPO_FOLDER}/${PACKAGE}"/pkg
      rm -rf "${REPO_FOLDER}/${PACKAGE}"/src
      rm -f "${REPO_FOLDER}/${PACKAGE}"/*.tar.*
      rm -f "${REPO_FOLDER}/${PACKAGE}"/PKGBUILD.rej
    elif [ $CLEAN_PACKAGES -eq 1 ] || [ $UPGRADE_PACKAGES -eq 1 ]; then
      if [ $UPGRADE_PACKAGES -eq 0 ]; then
        printf "\033[1;34m::\033[0m \033[1mCleaning \'${PACKAGE}\' package source tree...\033[0m\n"
      fi
      rm -rf "${REPO_FOLDER}/${PACKAGE}"/src/*build*
      rm -f "${REPO_FOLDER}/${PACKAGE}"/*.pkg.tar.*
      rm -f "${REPO_FOLDER}/${PACKAGE}"/PKGBUILD.rej
    fi
    return 0
  fi

  return 1
}

clean_repository()
{
  local PACKAGE=$1

  if [ "${PACKAGE}" != "NULL" ] && [ ! -z "${PACKAGE}" ]; then
    clean_package "${PACKAGE}"
    return 0
  else
    local DEFAULT_RESPONSE="y"
    printf "\033[1;33m::\033[0m \033[1mWARNING: No packages given to be cleaned. Do you want to clean all packages inside the folder? [Y/n] \033[0m"
    read RESPONSE
    if [ -z "${RESPONSE}" ]; then RESPONSE="${DEFAULT_RESPONSE}"; fi
    case $(char 1 $(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')) in
      y)
        cd "${REPO_FOLDER}"
          for package in $(ls); do
            clean_package "${package}"
          done
        cd - >/dev/null
        return 0
        ;;
      *) break ;;
    esac

    if [ $PURGE_PACKAGES -eq 1 ]; then
      DEFAULT_RESPONSE="n"
      printf "\033[1;33m::\033[0m \033[1m         Do you want to clean the entire folder? [y/N] \033[0m"
      read RESPONSE
      if [ -z "${RESPONSE}" ]; then RESPONSE="${DEFAULT_RESPONSE}"; fi
      case $(char 1 $(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')) in
        y)
          cd "${REPO_FOLDER}"
            for folder in $(/bin/ls); do
              rm -rf "${folder}"
            done
          cd - >/dev/null
          return 0
          ;;
        *) return 1 ;;
      esac
    fi
  fi

  return 0
}

clone_package()
{
  local PACKAGE=$1
  local UPGRADE=$2
  local EDIT=$3

  if [ ! -f "${REPO_FOLDER}/${PACKAGE}/PKGBUILD" ]; then
    printf "\033[1;34m::\033[0m \033[1mAttempting to download ${PACKAGE}...\033[0m\n"

    for GITURL in $(array -1 "${REPOSITORIES}"); do
      if [ ! -z "${GITURL}" ]; then
        if [ $(echo "${GITURL}" | grep "aur") ]; then
          printf "\033[1;33m::\033[0m \033[1mWARNING: Searching for ${PACKAGE} in AUR. It is recommended to --edit and read the PKGBUILD before continuing...\033[0m\n"
          printf "\033[1;33m::\033[0m \033[1m         Do you want to cancel this request? [Y/n]\033[0m "
          local DEFAULT_RESPONSE="y"
          read RESPONSE
          if [ -z "${RESPONSE}" ]; then RESPONSE="${DEFAULT_RESPONSE}"; fi
          case $(char 1 $(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')) in
            n) ;;
            y) exit 1 ;;
            *) exit 1 ;;
          esac
        fi
        GIT_TERMINAL_PROMPT=0 git clone ${GITURL}/${PACKAGE}.git ${REPO_FOLDER}/${PACKAGE} >/dev/null 2>&1
        if [ $? -eq 0 ]; then break; fi
      fi
    done

    if [ ! -d "${REPO_FOLDER}/${PACKAGE}" ]; then
      printf "\033[1;33m::\033[0m \033[1mWARNING: ${PACKAGE} not found in any of the repositories! Skipping...\033[0m\n"
      return 1
    fi

    cd "${REPO_FOLDER}/${PACKAGE}"
    if [ ! -z $EDIT ] && [ $EDIT -eq 1 ]; then edit_package ${PACKAGE}; fi
    makepkg --printsrcinfo > .SRCINFO
    cd - >/dev/null 2>&1

    printf "\033[1;32m::\033[0m \033[1m${PACKAGE} was succesfully downloaded. Building...\033[0m\n"
  else
    printf "\033[1;34m::\033[0m \033[1m${PACKAGE} already exists. Building...\033[0m\n"

    # Update repository
    cd "${REPO_FOLDER}/${PACKAGE}"

    git restore .
    if [ ! -z $UPGRADE ] && [ $UPGRADE -eq 1 ]; then git pull; fi
    if [ ! -z $EDIT ] && [ $EDIT -eq 1 ]; then edit_package ${PACKAGE}; fi
    if [ ! -f .SRCINFO ]; then makepkg --printsrcinfo > .SRCINFO; fi
    cd - >/dev/null 2>&1
  fi

  return 0
}

edit_package()
{
  local PACKAGE=$1

  if [ ! -z "${PACKAGE}" ]; then
    cd "${REPO_FOLDER}/${PACKAGE}"
    local SKIP_EDIT=0
    if [ -f "PKGBUILD.patch" ]; then
      printf "\033[1;33m::\033[0m \033[1mWARNING: A patch file for PKGBUILD has been found. What do you want to do? [DELETE/read/skip]\033[0m\n"
      local RESPONSE=""
      local DEFAULT_RESPONSE="delete"
      read RESPONSE
      if [ -z "${RESPONSE}" ]; then RESPONSE="${DEFAULT_RESPONSE}"; fi
      RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')
      case "${RESPONSE}" in
        skip) SKIP_EDIT=1 ;;
        read)
          SKIP_EDIT=1
          patch -N PKGBUILD < PKGBUILD.patch > /dev/null 2>&1
          cat PKGBUILD | less
          ;;
        delete|*) rm PKGBUILD.patch ;;
      esac
    fi

    if [ $SKIP_EDIT -eq 0 ]; then
      git restore PKGBUILD
      cp PKGBUILD PKGBUILD.editor
      local EDITOR=$(get_editor)
      if [ ! -z $EDITOR ]; then
        $EDITOR PKGBUILD.editor
        if [ ! -z "$(diff PKGBUILD PKGBUILD.editor)" ]; then
          diff PKGBUILD PKGBUILD.editor > PKGBUILD.patch
          printf "\033[1;32m::\033[0m \033[1mA patch for PKGBUILD has succesfully been created.\033[0m\n"
        fi
        rm PKGBUILD.editor
      fi
    fi
    cd - >/dev/null 2>&1
  else
    return 1
  fi

  return 0
}

run_pacman()
{
  pacman $@
}

