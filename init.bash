#! /bin/bash

function symlink() {
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext="${filename##*.}"
  local without_ext="${filename//".$ext"/}"
  local to && to="$(realpath "$script")"
  local from="$HOME/bin/$without_ext"

  [ -f "$from" ] && rm "$from"

  ln -s "$to" "$from"
}

function main() {
  hostname=$(hostname)
  if [ "$hostname" != 'WTMZ-TMZ006298' ]; then
    echo "not implemented for $hostname yet"
    exit 1
  fi

  for script in ./common/bin/*/*; do
    symlink "$script"
  done

  for script in ./"$hostname"/bin/*/*; do
    symlink "$script"
  done
}

main
