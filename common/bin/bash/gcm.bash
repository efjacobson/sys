#! /bin/bash

main() {
  local message="$*"
  [ -z "${message}" ] && message='wip'

  local toplevel && toplevel=$(git rev-parse --show-toplevel)
  if [[ $toplevel != *"tmz-apps"* ]]; then
    git commit -m "$message"
    exit
  fi

  local branch && branch=$(git symbolic-ref --short HEAD)
  if [[ "$branch" =~ ^[0-9]+-.+$ ]]; then
    local ticket_number && ticket_number=$(echo "$branch" | awk -F'[^0-9]+' '{ print $1 }')
    git commit -m "re: #$ticket_number $message"
  else
    git commit -m "$message"
  fi
}

main "$@"
