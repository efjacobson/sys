#!/usr/bin/env bash

main() {
  git fetch
  pull_argument="$1"
  if [ -z "$pull_argument" ]; then
    pull_argument='--no-rebase'
  fi
  git pull origin "$(git symbolic-ref --short HEAD)" "$pull_argument"
}

main "$1"
