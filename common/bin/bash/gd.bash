#! /bin/bash

main() {
  if [ "$1" != '' ]; then
    git diff "$1"
    return
  fi

  local ignores=()
  if [ 'WTMZ-TMZ006298' == "$(hostname)" ]; then
    ignores+=('provisioning/docker/environment.sh')
    ignores+=('provisioning/docker/vhost.conf.tpl')
  fi

  local temp_dir && temp_dir=$(mktemp -d)

  for ignore in "${ignores[@]}"; do
    if [ -f "$ignore" ]; then
      mv "$ignore" "$temp_dir"
      git checkout -q "$ignore"
    fi
  done

  git diff

  for ignore in "${ignores[@]}"; do
    if [ -f "$ignore" ]; then
      mv "$temp_dir/$(basename "$ignore")" "$ignore"
    fi
  done

  rm -rf "$temp_dir"
}

main "$@"
