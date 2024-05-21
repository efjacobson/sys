#!/usr/bin/env bash

main() {
  local branch && branch=$(git symbolic-ref --short HEAD)
  local toplevel && toplevel=$(git rev-parse --show-toplevel)
  if [[ $toplevel == *"efjacobson"* ]]; then
    git push origin "${branch}"
    exit 0
  fi

  for protected in 'master' 'main' 'release-next'; do
    if [[ "${branch}" == "${protected}" ]]; then
      echo "don't push ${branch}..."
      exit 1
    fi
  done

  pre_push=$(find . -maxdepth 3 -name pre-push -type f | head -n 1)
  if ! [[ -f "${pre_push}" ]]; then
    git push origin "${branch}"
    exit
  fi

  hashbang=$(head -n 1 "${pre_push}")
  if [[ "${hashbang}" != '#!/bin/bash' ]]; then
    git push origin "${branch}"
    exit
  fi

  self="${BASH_SOURCE[0]}"
  while [ -L "${self}" ]; do
      self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
      self="$(readlink "${self}")"
      [[ ${self} != /* ]] && self="${self_dir}/${self}"
  done
  self="$(readlink -f "${self}")"
  selfdir=$(dirname "${self}")
  selfname=$(basename "${self}")
  tpl="${selfdir}/${selfname}.tpl"

  cp "${pre_push}" "${pre_push}.bak"
  head -n 1 "${pre_push}.bak" > "${pre_push}"
  cat "${tpl}" >> "${pre_push}"
  tail -n +2 "${pre_push}.bak" >> "${pre_push}"

  git push origin "${branch}"

  mv "${pre_push}.bak" "${pre_push}"
}

main
