#! /bin/bash

main() {
  local file="$1"
  if [ ! -f "$file" ]; then
    printf '%s does not exist!' "$file"
    exit 1
  fi
  xsel -ib <"$file"
  exit 0
}

main "$@"
