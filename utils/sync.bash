#! /bin/bash

declare -r PREFIX='\033['
declare -r RED="${PREFIX}0;31m"
declare -r NC="${PREFIX}0m"
declare -r GREEN="${PREFIX}0;32m"

force=false
verbose=true
while [ $# -gt 0 ]; do
  case "$1" in
  -f) force=true ;;
  -v) verbose=true ;;
  *) ;;
  esac
  shift
done

reverse_sync_files=()
case "$(hostname)" in
NeurAspire)
  reverse_sync_files+=("$HOME/.config/Code - OSS/User/settings.json")
  ;;
neuraspire)
  reverse_sync_files+=("$HOME/.config/Code - OSS/User/settings.json")
  ;;
hbot)
  reverse_sync_files+=("$HOME/.config/Code - OSS/User/settings.json")
  ;;
*) ;;
esac

log_error() {
  local message="$1"
  local caller="${FUNCNAME[1]}"

  echo -e "${RED}${caller}():${NC} $message"
}

log() {
  local message="$1"
  local caller="${FUNCNAME[1]}"

  $verbose && echo -e "${GREEN}${caller}():${NC} $message"
}

sync_file() {
  local from="$1"
  local to="$2"

  for i in "${reverse_sync_files[@]}"; do
    if [ "$i" == "$to" ]; then
      return
    fi
  done

  local dir && dir=$(dirname "$to")
  [ ! -d "$dir" ] && mkdir -p "$dir"

  if [ ! "$(cp "$from" "$to")" ]; then
    log "copied $(basename "$from") to $dir/"
  else
    log_error "FAILED copying $(basename "$from") to $dir/"
  fi
}

sync_files_reverse() {
  if [ 0 == ${#reverse_sync_files[@]} ]; then
    return
  fi

  local to
  for from in "${reverse_sync_files[@]}"; do
    to="$(project_root)/$(hostname)/filesystem${from}"
    sync_file "$from" "$to"
  done
}

sync_files() {
  local filesystem && filesystem="$(project_root)/$(hostname)/filesystem"
  if [ ! -d "$filesystem" ]; then
    log_error "$filesystem is not a directory..."
    return
  fi

  find "$filesystem" -type f | while read -r _file; do sync_file "$_file" "${_file//"$filesystem"/}"; done

  sync_files_reverse
}

user_bin=false
set_user_bin() {
  if [ false != $user_bin ]; then
    return
  fi

  case "$(hostname)" in
  'Geriatrix')
    user_bin='._/bin/path'
    ;;
  'NeurAspire')
    user_bin='._/bin'
    ;;
  'neuraspire')
    user_bin='._/bin'
    ;;
  'hbot')
    user_bin='._/bin'
    ;;
  'WTMZ-TMZ006298')
    user_bin='bin'
    ;;
  *)
    echo 'no bin for user!'
    exit 1
    ;;
  esac
}

sync_script() {
  set_user_bin
  local script="$1"
  local filename && filename=$(basename -- "$script")
  local ext && ext="$(get_ext "$script")"
  local without_ext="${filename//".$ext"/}"

  # if ! $force && [ '' != "$(command -v "$without_ext")" ]; then
  #   log "skipping $without_ext, you already have one in your path..."
  #   return
  # fi

  local to && to="$(realpath "$script")"
  local from="$HOME/$user_bin/$without_ext"
  if [ -f "$from" ]; then
    rm "$from"
  fi

  # if ! $force && [ "$(readlink "$from")" == "$to" ]; then
  #   log "skipping $without_ext, it is already linked"
  #   return
  # fi

  if [ ! -d "$HOME/$user_bin" ]; then
    mkdir -p "$HOME/$user_bin"
  fi

  # $force && rm "$from"
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

is_Geriatrix=false
is_NeurAspire=false
is_WTMZ=false
set_identity() {
  if [ 'Geriatrix' == "$(hostname)" ]; then
    is_Geriatrix=true
    return
  fi
  if [ 'NeurAspire' == "$(hostname)" ]; then
    is_NeurAspire=true
    return
  fi
  if [ 'hbot' == "$(hostname)" ]; then
    is_hbot=true
    return
  fi
  if [ 'WTMZ-TMZ006298' == "$(hostname)" ]; then
    is_WTMZ=true
  fi
}

main() {
  local implemented=('hbot' 'neuraspire' 'NeurAspire' 'Geriatrix' 'WTMZ-TMZ006298')
  local hostname && hostname=$(hostname)
  if [[ ! " ${implemented[*]} " =~ " ${hostname} " ]]; then
    echo "not implemented for $hostname yet"
    exit 0
  else
    set_identity
  fi

  shared=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && printf '%s/shared.bash' "$(pwd)")
  source "$shared"

  sync_files
  sync_scripts

  echo -e "${GREEN}${FUNCNAME[0]}():${NC} finished run with force:$force, verbose:$verbose"

  exit 0
}

main
