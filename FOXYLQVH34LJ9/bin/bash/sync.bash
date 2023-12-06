#! /bin/bash

src='/Users/eric.jacobson/_'
[ -d "${src}" ] || exit

log () {
  from_epoch=$(gdate -u "+%s %N")
  seconds=$(cut -d' ' -f1 <<< "${from_epoch}")
  nanoseconds=$(cut -d' ' -f2 <<< "${from_epoch}")
  datetime=$(gdate -u --date="@${seconds}" "+%FT%T")
  microseconds=$(cut -c1-6 <<< "${nanoseconds}")
  echo "${datetime}.${microseconds}Z ${1}"
}

echo ''
log 'sync:start'

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
    self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
    self="$(readlink "${self}")"
    [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"

lockfile="${self}.lock"
[ -e "${lockfile}" ] && log "sync:locked" && exit

dest='/Volumes/users-eric-jacobson/_'
if ! [ -e "$(dirname $dest)" ]; then
  log 'sync:unmounted'
  exit
fi

[ -d "${dest}" ] || mkdir "${dest}" || exit
touch "${lockfile}"
trap 'rm ${lockfile} && log "'"sync:exit"'" && echo "'""'"' EXIT
log 'sync:rsync-start'
rsync -rltgoDq --inplace --delete --exclude={.DS_Store,node_modules,vendor} ${src}/ ${dest}
log 'sync:rsync-end'

sleep 11