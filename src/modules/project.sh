#!/bin/sh

PROJECT_NAME=$(basename $0)
PROJECT_VERSION="0.0.17"
REPO_FOLDER="${HOME}/.cache/pacbuilder"
mkdir -p "${REPO_FOLDER}"

if [ -f "/etc/pacbuilder.conf" ]; then . /etc/pacbuilder.conf; fi

REPOSITORIES=""
if [ -f "/etc/pacbuilder.d/mirrorlist" ]; then REPOSITORIES=$(grep -v "#" /etc/pacbuilder.d/mirrorlist); fi
if [ -z "${REPOSITORIES}" ]; then REPOSITORIES="https://gitlab.archlinux.org/archlinux/packaging/packages"; fi

PACKAGE_PWD=""
DEPENDENCY_RABBIT_HOLE=0
CLEAN_PACKAGES=0
EDIT_PACKAGES=0
LIST_PACKAGES=0
PURGE_PACKAGES=0
UPGRADE_PACKAGES=0
SKIP_PGP_SIGNATURE=""

