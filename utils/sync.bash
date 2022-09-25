#! /bin/bash

declare -r PREFIX='\033['
declare -r RED="${PREFIX}0;31m"
declare -r NC="${PREFIX}0m"
declare -r GREEN="${PREFIX}0;32m"

force='false'
verbose='false'
while [ $# -gt 0 ]; do
  case "$1" in
  -f) force='true' ;;
  -v) verbose='true' ;;
  *) ;;
  esac
  shift
done

log_error() {
  local message="$1"
  local caller="${FUNCNAME[1]}"

  echo -e "${RED}${caller}():${NC} $message"
}

log() {
  local message="$1"
  local caller="${FUNCNAME[1]}"

  [ "$verbose" == 'true' ] && echo -e "${GREEN}${caller}():${NC} $message"
}

sync_file() {
  local path="$1"
  if [ -f "$path" ]; then
    if [ "$force" == 'false' ] && [ '' == "$(cmp "$file" "$path")" ]; then
      log "skipping $(basename "$file"), it is identical"
      return
    fi
    # rm "$path"
  fi

  local dir && dir=$(dirname "$path")
  [ ! -d "$dir" ] && mkdir -p "$dir"

  # printf '%s' "$(whoami)"
  # local owner_group=$(stat -c "%U:%G" "$path")
  if [ "$(whoami):$(whoami)" != "$(stat -c "%U:%G" "$path")" ]; then
    sudo cp "$file" "$path"
  else
    cp "$file" "$path"
  fi
  log "copied $(basename "$file") to $dir/"
}

sync_files() {
  local filesystem && filesystem="$(project_root)/$(hostname)/filesystem"
  if [ ! -d "$filesystem" ]; then
    log_error "$filesystem is not a directory..."
    return
  fi

  find "$filesystem" -type f | while read -r file; do sync_file "${file//"$filesystem"/}"; done
}

user_bin='bin'
set_user_bin() {
  if [ 'Geriatrix' == "$(hostname)" ]; then
    user_bin='._/bin/path'
    return
  fi
  if [ 'NeurAspire' == "$(hostname)" ]; then
    user_bin='._/bin'
  fi
}

sync_script() {
  set_user_bin
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext && ext="$(get_ext "$script")"
  local without_ext="${filename//".$ext"/}"

  if [ "$force" == 'false' ] && [ '' != "$(command -v "$without_ext")" ]; then
    log "skipping $without_ext, you already have one in your path..."
    return
  fi

  local to && to="$(realpath "$script")"
  local from="$HOME/$user_bin/$without_ext"

  if [ "$force" == 'false' ] && [ "$(readlink "$from")" == "$to" ]; then
    log "skipping $without_ext, it is already linked"
    return
  fi

  if [ ! -d "$HOME/$user_bin" ]; then
    mkdir -p "$HOME/$user_bin"
  fi

  ln -s "$to" "$from"
  log "symlinked $without_ext to $script"
}

sync_scripts_WTMZ-TMZ006298() {
  for script in ./"$hostname"/bin/*/*; do
    sync_script "$script"
  done

  for script in ./common/bin/*/*; do
    sync_script "$script"
  done
}

sync_scripts_default() {
  all=()
  sources=("$(project_root)/common" "$(project_root)/$(hostname)")
  for source in "${sources[@]}"; do
    if [ -d "$source"/bin ]; then
      mapfile -t new < <(ls -d "$source"/bin/*)
      all=("${all[@]}" "${new[@]}")
    fi
  done

  for shell in "${all[@]}"; do
    find "$shell" -type f | while read -r script; do sync_script "$script"; done
  done
}

sync_scripts() {
  local fn && fn="sync_scripts_$(hostname)"
  if [ "$(type -t "$fn")" == 'function' ]; then
    eval "$fn"
    return
  fi

  sync_scripts_default
}

implemented=('NeurAspire' 'Geriatrix' 'WTMZ-TMZ006298')
main() {
  local hostname && hostname=$(hostname)
  if [[ ! " ${implemented[*]} " =~ " ${hostname} " ]]; then
    echo "not implemented for $hostname yet"
    return
  fi

  shared=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && printf '%s/shared.bash' "$(pwd)")
  source "$shared"

  sync_files
  sync_scripts

  exit 0
}

main
