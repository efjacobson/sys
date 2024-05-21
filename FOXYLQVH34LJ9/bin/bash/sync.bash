#!/usr/bin/env bash

log () {
  from_epoch=$(gdate -u "+%s %N")
  seconds=$(cut -d' ' -f1 <<< "${from_epoch}")
  nanoseconds=$(cut -d' ' -f2 <<< "${from_epoch}")
  datetime=$(gdate -u --date="@${seconds}" "+%FT%T")
  microseconds=$(cut -c1-6 <<< "${nanoseconds}")
  echo "[sync] ${datetime}.${microseconds}Z - ${1}"
}

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
    self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
    self="$(readlink "${self}")"
    [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"

lockfile="${self}.lock"

echo ''
log 'start'
#log "whoami: $(whoami)"
trap 'log "'"end"'" && echo "'""'" && [ -e ${lockfile} ] && rm ${lockfile}' EXIT

[ -e "${lockfile}" ] && log "locked" && exit
touch "${lockfile}"

blockfile="${self}.block"
[ -e "${blockfile}" ] && log "blocked" && exit

src=$(yq -r '.src' "${self}.config")
if ! [ -d "${src}" ]; then
  log "invalid src: ${src}"
  exit
fi

dest=$(yq -r '.dest' "${self}.config")
if ! [ -d "$(dirname "${dest}")" ]; then
  log "invalid dest: ${dest}"
  exit
fi

ignore=$(yq -r '.ignore' "${self}.config")

from_src=$(yq -r '.from_src' "${self}.config")
from_dest=$(yq -r '.from_dest' "${self}.config")

log 'rsync:start'
rsync -rltgoDq --inplace --delete --exclude={.git,.DS_Store,node_modules,vendor,"${ignore}/","$(basename "$from_dest")"} "${src}/" "${dest}"
rsync -rltgoDq --inplace --delete "${from_src}/" "${from_dest}"
log 'rsync:end'

sleep 11
