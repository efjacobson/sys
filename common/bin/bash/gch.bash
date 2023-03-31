#! /bin/bash

function main() {
  if ! [[ $(git status --porcelain) ]]; then
    echo 'already clean'
    exit
  fi
  if [ "$1" != "" ]; then
    echo "dont enter a file name chucklehead, this is for getting rid of everything"
  else
    tmp="$(mktemp -d)"
    for file in $(git diff --name-only); do
      rsync -R "$file" "$tmp/"
      git checkout -q "$file"
    done
    (sleep 300 && rm -rf "$tmp") &
    echo "oopsie woopsie? the files with changes are in $tmp, they will be deleted in 5 minutes."
  fi
}

main "$1"
