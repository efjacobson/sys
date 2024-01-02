#! /bin/bash

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
    self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
    self="$(readlink "${self}")"
    [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"

for d in /home/*; do
  user="$(basename "$d")"
  break
done

logfile="/home/${user}/_/log/sleep.yaml"

if ! [ -e "${logfile}" ]; then
  echo '[]' > "${logfile}"
fi

log="$(yq '.' "${logfile}")"
percentage=$(upower -i "$(upower -e | grep battery)" | grep percentage | tr -d ' ' | cut -d':' -f2)
log="$(
  yq -y \
    --arg percentage "${percentage}" \
    --arg what "${1}:${2}" \
    --arg when "$(date +%s)" \
    --arg reporter "${self}" \
    '. += [{percentage:$percentage,reporter:$reporter,what:$what,when:$when|tonumber}]' \
  <<< "${log}" \
)"

yq -y '.' <<< "${log}" > "${logfile}"
