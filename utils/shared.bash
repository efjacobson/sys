#!/usr/bin/env bash

get_ext() {
  local filepath="$1"
  local filename && filename=$(basename -- "$filepath")
  local ext="${filename##*.}"
  echo "$ext"
  return 0
}

project_root() {
  local here && here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  echo "$(dirname "$here")"
  return 0
}
