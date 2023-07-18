#! /bin/bash

main() {
  local ignores=()
  # if [ 'WTMZ-TMZ006298' == "$(hostname)" ]; then
  #   ignores+=('provisioning/docker/environment.sh')
  #   ignores+=('provisioning/docker/vhost.conf.tpl')
  # fi

  if [ "$1" != "" ]; then
    git add "$1"
  else
    git add -A

    for ignore in "${ignores[@]}"; do
      if [ -f "$ignore" ]; then
        git restore --staged "$ignore"
      fi
    done
  fi
}

main "$@"
