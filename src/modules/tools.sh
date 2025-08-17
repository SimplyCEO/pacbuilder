#!/bin/sh

source /etc/pacbuilder.d/modules/project.sh

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

get_editor()
{
  if [ -z $EDITOR ]; then
    local EDITOR_ARRAY="vim vi nano neovim ed"
    for editor in $(array -1 "${EDITOR_ARRAY}"); do
      if which $editor >/dev/null 2>&1; then echo $editor; return 0; fi
    done
  else
    echo $EDITOR
    return 0
  fi

  return 1
}

