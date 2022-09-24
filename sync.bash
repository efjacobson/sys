#! /bin/bash

declare -r PREFIX='\033['
declare -r RED="${PREFIX}0;31m"
declare -r NC="${PREFIX}0m"
declare -r GREEN="${PREFIX}0;32m"

verbose='false'
while [ $# -gt 0 ]; do
  case "$1" in
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
  local file="$1"
  local search && search="$(hostname)/filesystem"

  local path="${file//"$search"/}"
  if [ -f "$path" ]; then
    if [ '' == "$(cmp "$file" "$path")" ]; then
      log "skipping $(basename "$file"), it is identical"
      return
    fi
    rm "$path"
  fi

  local dir && dir=$(dirname "$file")
  [ ! -d "$dir" ] && mkdir -p "$dir"

  cp "$file" "$path"
  log "copied $(basename "$file") to $(dirname "$path")/"
}

sync_filesystem() {
  local filesystem && filesystem="$(hostname)"/filesystem
  if [ ! -d "$filesystem" ]; then
    log_error "$(realpath "$filesystem") is not a directory...\n"
    return
  fi

  find "$(hostname)"/filesystem -type f | while read -r file; do sync_file "$file"; done
}

sync_script() {
  local function_name="${FUNCNAME[0]}"
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext="${filename##*.}"
  local without_ext="${filename//".$ext"/}"
  local to && to="$(realpath "$script")"
  local from="$HOME/bin/$without_ext"

  if [ "$(readlink "$from")" == "$to" ]; then
    log "skipping $without_ext, it is already linked"
    return
  fi

  ln -s "$to" "$from"
  log "$function_name(): symlinked $without_ext to $script"
}

sync_scripts_default() {
  for script in ./"$hostname"/bin/*/*; do
    sync_script "$script"
  done

  for script in ./common/bin/*/*; do
    sync_script "$script"
  done
}

sync_scripts_Geriatrix() {
  all=()
  sources=('common' "$(hostname)")
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

implemented=('Geriatrix' 'WTMZ-TMZ006298')
main() {
  local hostname && hostname=$(hostname)
  if [[ ! " ${implemented[*]} " =~ " ${hostname} " ]]; then
    echo "not implemented for $hostname yet"
    return
  fi

  sync_filesystem "$hostname"

  # if [ 'Geriatrix' == "$hostname" ]; then
  #   sync_script_Geriatrix
  #   return
  # fi

  sync_scripts
  exit 0
}

main
