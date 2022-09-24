#! /bin/bash

function symlink_script() {
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext="${filename##*.}"
  local without_ext="${filename//".$ext"/}"
  local to && to="$(realpath "$script")"
  local from="$HOME/bin/$without_ext"

  [ -f "$from" ] && rm "$from"
  [ ! -d "$(dirname "$from")" ] && mkdir -p "$(dirname "$from")"

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
  if [ ! -d "$hostname"/filesystem ]; then
    # todo: log
    return
  fi
  find "$hostname"/filesystem -type f | while read -r file; do sync_file "$file"; done
}

function sync_script_Geriatrix() {
  all=()
  sources=('common' "$(hostname)")
  for source in "${sources[@]}"; do
    if [ -d "$source"/bin ]; then
      mapfile -t new < <(ls -d "$source"/bin/*)
      all=("${all[@]}" "${new[@]}")
    fi
  done

  for shell in "${all[@]}"; do
    find "$shell" -type f | while read -r script; do symlink_script "$script"; done
  done
}

function sync_scripts() {
  local fn && fn="sync_scripts_$(hostname)"
  if [ "$(type -t "$fn")" == function ]; then
    eval "$fn"
    return
  fi

  for script in ./"$hostname"/bin/*/*; do
    symlink_script "$script"
  done

  for script in ./common/bin/*/*; do
    symlink_script "$script"
  done
}

implemented=('Geriatrix' 'WTMZ-TMZ006298')
function main() {
  local hostname && hostname=$(hostname)
  if [[ ! " ${implemented[*]} " =~ " ${hostname} " ]]; then
    echo "not implemented for $hostname yet"
    return
  fi

  sync_filesystem "$hostname"

  if [ 'Geriatrix' == "$hostname" ]; then
    sync_script_Geriatrix
    return
  fi

  sync_script_default
  exit 0
}

main
