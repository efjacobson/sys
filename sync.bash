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

symlink_script() {
  local function_name="${FUNCNAME[0]}"
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext="${filename##*.}"
  local without_ext="${filename//".$ext"/}"
  local to && to="$(realpath "$script")"
  local from="$HOME/bin/$without_ext"

  local t && t=$(type "$without_ext")
  if [ "$t" != "$without_ext is $from" ]; then
    log_error "skipping $(realpath "$script"), there already is a \"$without_ext\" in your path..."
    return
  fi

  if [ -f "$from" ]; then
    if [ "$(readlink "$from")" == "$to" ]; then
      log "skipping $from, it is already linked to $to"
      return
    fi
    rm "$from"
  fi

  ln -s "$to" "$from"
  log "$function_name(): symlinked $without_ext to $script"
}

sync_scripts() {
  local type="$1"
  for script in ./"$type"/bin/*/*; do
    symlink_script "$script"
  done
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

main() {
  if [ "$(hostname)" != 'WTMZ-TMZ006298' ]; then
    log_error "not implemented for $(hostname) yet"
    exit 1
  fi

  sync_filesystem
  sync_scripts common
  sync_scripts "$(hostname)"
}

main
