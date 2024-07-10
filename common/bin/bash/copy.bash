#! /usr/bin/env bash
set -e

main() {
  local file="$1"
  if [ ! -f "$file" ]; then
    printf '%s does not exist!\n' "$file"
    exit 1
  fi
  if [[ $OSTYPE == 'darwin'* ]]; then
    pbcopy <"$file"
  else
    xsel -ib <"$file"
  fi
  exit 0
}

main "$@"
