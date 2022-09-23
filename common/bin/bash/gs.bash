#! /bin/bash

function main() {
  local work=(
    'provisioning/docker/environment.sh'
    'provisioning/docker/vhost.conf.tpl'
  )

  local other=()

  local moved=()
  local tmpdir
  tmpdir=$(mktemp -d)

  local ignores=("${other[@]}" "${work[@]}")
  for ignore in "${ignores[@]}"; do
    if [[ -f "$ignore" && $(git ls-files "$ignore") ]]; then
      mv "$ignore" "$tmpdir"
      git checkout -q "$ignore"
      moved+=("$ignore")
    fi
  done

  git status

  for ignore in "${moved[@]}"; do
    if [[ -f "$ignore" && $(git ls-files "$ignore") ]]; then
      mv "$tmpdir/$(basename "$ignore")" "$ignore"
    fi
  done

  rm -rf "$tmpdir"
}

main
