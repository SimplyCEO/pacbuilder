#!/bin/sh

# $(char 3 pacbuilder) = c
char()
{
  echo "$2" | cut -c $1
}

# $(strncmp diff1 diff2 4) = 0
# $(strncmp diff1 diff2 5) = 1
strncmp()
{
  if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then echo 1; return 1; fi

  local c=1
  while [ $c -le $3 ]; do
    if [ $(char $c $1) != $(char $c $2) ]; then echo 1; return 1; fi
    c=$((c+1))
  done

  echo 0; return 0
}

# $(strlen pacbuilder) = 11
strlen()
{
  echo "$1" | wc -c
}

