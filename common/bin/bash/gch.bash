#! /bin/bash

function main() {
  if ! [[ $(git status --porcelain) ]]; then
    echo 'already clean'
    exit
  fi

  if [ -n "${1}" ]; then
    echo "dont enter a file name chucklehead, this is for getting rid of everything"
    exit
  fi

  mtmp="$(mktemp -d)"
  tmp="$(dirname "${mtmp}")/git-checkout-bak-$(date +%s)-$(basename "$(pwd)")-$(basename "${mtmp}")"
  mv "${mtmp}" "${tmp}"
  any=false
  for file in $(git diff --name-only); do
    any=true
    [ -e "${file}" ] && rsync -R "${file}" "${tmp}/"
    git checkout -q "${file}"
  done
  for file in $(git ls-files --others --exclude-standard); do
    any=true
    mv "${file}" "${tmp}/"
  done
  if [ "${any}" = false ]; then
    echo 'nothing to do'
    exit
  fi
  echo "oopsie woopsie? the files are in ${tmp}"
}

main "${1}"
