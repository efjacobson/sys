#! /bin/bash

get_ext() {
  local filepath="$1"
  local filename && filename=$(basename -- "$filepath")
  local ext="${filename##*.}"
  echo "$ext"
  return 0
}

project_root() {
  local me && me="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  echo "$(dirname "$me")"
  return 0
}
