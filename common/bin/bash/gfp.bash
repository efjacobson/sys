#! /bin/bash

main() {
  git fetch
  pull_argument="$1"
  if [ '' == "$pull_argument" ]; then
    pull_argument='--no-rebase'
  fi
  git pull origin "$(git symbolic-ref --short HEAD)" "$1"
}

main "$1"
