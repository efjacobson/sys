#! /usr/bin/env bash
set -e

main() {
  git commit -S --amend --no-edit
}

main
