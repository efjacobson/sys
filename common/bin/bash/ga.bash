#! /usr/bin/env bash
set -e

main() {
  if [ -n "${1}" ]; then
    git add "$1"
    shift
    if [ -z "${1}" ]; then
      exit 0
    fi
    main "${@}"
  else
    git add -A
  fi

}

main "${@}"