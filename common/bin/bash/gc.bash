#! /usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "what do you want to checkout?"
else
  mtmp="$(mktemp -d)"
  tmp="$(dirname "${mtmp}")/git-checkout-bak-$(date +%s)-$(basename "$(pwd)")-$(basename "${mtmp}")"
  mv "${mtmp}" "${tmp}"

  file='false'
  for arg in "$@"; do
    git checkout "${arg}"
    ! [ -e "${arg}" ] && continue
    file='true'
    rsync -R "${arg}" "${tmp}/"
  done

  [[ "${file}" == 'true' ]] && echo "oopsie woopsie? the files are in ${tmp}"
fi
