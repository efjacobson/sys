#! /bin/bash

work=(
  'provisioning/docker/environment.sh'
  'provisioning/docker/vhost.conf.tpl'
)

other=(
  'wtf.test'
)

ignores=("${other[@]}" "${work[@]}")
tmpdir=$(mktemp -d)

for ignore in "${ignores[@]}"; do
  if [ -f "$ignore" ]; then
    if [[ $(git ls-files "$ignore") ]]; then
      echo "$ignore is tracked, moving"
      mv "$ignore" "$tmpdir"
      git checkout -q "$ignore"
    fi
  fi
done

git status

for ignore in "${ignores[@]}"; do
  if [ -f "$ignore" ]; then
    if [[ $(git ls-files "$ignore") ]]; then
      echo "$ignore is tracked, moving back"
      mv "$tmpdir/$(basename "$ignore")" "$ignore"
    fi
  fi
done

rm -rf "$tmpdir"
