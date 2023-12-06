#! /bin/bash

main() {
  branch_name="${1}"
  [ -z "${branch_name}" ] && echo 'delete what?' && exit 1

  local toplevel && toplevel=$(git rev-parse --show-toplevel)
  if [[ $toplevel == *"efjacobson"* ]]; then
    git branch -D "${branch_name}"
    exit 0
  fi

  for protected in 'master' 'main' 'release-next'; do
    if [[ "${branch_name}" == "${protected}" ]]; then
      echo "don't delete ${branch_name}..."
      exit 1
    fi
  done

  git branch -D "${branch_name}"
}

main "${@}"