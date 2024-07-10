#! /usr/bin/env bash
set -e

main() {
  local programs=('clonezilla' 'git-delta' 'bat' 'shfmt')

  # shellcheck disable=SC2046
  sudo pacman -Syyuv --needed $(printf " %s" "${programs[@]}")
}

main
