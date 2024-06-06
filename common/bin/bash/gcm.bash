#!/usr/bin/env bash

main() {
  local message="$*"
  [ -z "${message}" ] && message='wip'

  gpgarg=''
  if [ -x "$(command -v gpg)" ]; then
    gpgarg='-S'
  fi

  local toplevel && toplevel=$(git rev-parse --show-toplevel)
  if [[ $toplevel != *"tmz-apps"* ]]; then
    git commit "${gpgarg}" -m "${message}"
    exit
  fi

  local branch && branch=$(git symbolic-ref --short HEAD)
  if [[ "$branch" =~ ^[0-9]+-.+$ ]]; then
    local ticket_number && ticket_number=$(echo "$branch" | awk -F'[^0-9]+' '{ print $1 }')
    git commit "${gpgarg}" -m "re: #${ticket_number} ${message}"
  else
    git commit "${gpgarg}" -m "${message}"
  fi
}

main "$@"
