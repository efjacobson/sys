#! /bin/bash

main() {
  local programs=('tmux' 'clonezilla' 'git-delta' 'bat' 'shfmt')

  # shellcheck disable=SC2046
  sudo pacman -Syyuv --needed $(printf " %s" "${programs[@]}")
}

main
