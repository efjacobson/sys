#! /bin/bash

function symlink_script() {
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext="${filename##*.}"
  local without_ext="${filename//".$ext"/}"
  local to && to="$(realpath "$script")"
  local from="$HOME/bin/$without_ext"

  [ -f "$from" ] && rm "$from"

  ln -s "$to" "$from"
}

function sync_file() {
  local file="$1"
  local hostname && hostname=$(hostname)
  local search="$hostname/filesystem"
  local path="${file//"$search"/}"
  [ -f "$path" ] && rm "$path"
  local dir && dir=$(dirname "$file")
  [ ! -d "$dir" ] && mkdir -p "$dir"
  cp "$file" "$path"
}

function sync_filesystem() {
  local hostname && hostname=$(hostname)
  find "$hostname"/filesystem -type f | while read -r file; do sync_file "$file"; done
}

function main() {
  local hostname && hostname=$(hostname)
  if [ "$hostname" != 'WTMZ-TMZ006298' ]; then
    echo "not implemented for $hostname yet"
    exit 1
  fi

  sync_filesystem "$hostname"

  for script in ./"$hostname"/bin/*/*; do
    symlink_script "$script"
  done

  for script in ./common/bin/*/*; do
    symlink_script "$script"
  done
}

main
