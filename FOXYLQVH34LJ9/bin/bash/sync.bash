#! /bin/bash

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

subdir=$(yq -r '.subdir' "${self}.config")

from_src=$(yq -r '.from_src' "${self}.config")
from_dest=$(yq -r '.from_dest' "${self}.config")

log 'rsync:start'
rsync -rltgoDq --inplace --delete --exclude={.git,.DS_Store,node_modules,vendor,"${subdir}/","$(basename "$from_dest")"} "${src}/" "${dest}"
rsync -rltgoDq --inplace --delete "${from_src}/" "${from_dest}"
log 'rsync:end'

if ! [ -d "${dest}${subdir}" ]; then
  mkdir -p "${dest}${subdir}"
fi

for f in "${src}${subdir}/"*; do
  if ! [ -d "${f}" ]; then
    continue
  fi
  if ! [ -f "${f}.7z" ]; then
    continue
  fi
  if ! [ -f "${f}.7z.sha512" ]; then
    continue
  fi
  dest_sha="${dest}${subdir}/$(basename "${f}").7z.sha512"
  if ! [ -f "${dest_sha}" ]; then
    cp -Rp "${f}.7z.sha512" "${dest}${subdir}/"
    cp -Rp "${f}.7z" "${dest}${subdir}/"
    log "${subdir}/$(basename "${f}").7z"
  fi
  if [ "$(cut -d' ' -f1 < "${f}.7z.sha512")" != "$(cut -d' ' -f1 < "${dest_sha}")" ]; then
    cp -Rp "${f}.7z.sha512" "${dest}${subdir}/"
    cp -Rp "${f}.7z" "${dest}${subdir}/"
    log "${subdir}/$(basename "${f}").7z"
  fi
done

sleep 11
