#! /bin/bash

main() {
  git fetch
  git pull origin "$(git symbolic-ref --short HEAD)" "$1"
}

main "$1"
