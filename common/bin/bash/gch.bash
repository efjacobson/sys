#! /bin/bash

function remove() {
  tmpdir="$1"
  file_path="$2"

  mv "$file_path" "$tmpdir/"
  git checkout -q "$file_path"
}

function restore() {
  tmpdir="$1"
  dir="$2"
  file_path="$3"

  mv "$tmpdir/$file_path" "$dir/$file_path"
}

function main() {
  if [ "$1" != "" ]; then
    echo "dont enter a file name chucklehead, this is for getting rid of everything"
  else
    tmpdir="$HOME/.gch.tmp"
    mkdir "$tmpdir"
    environment_file_path=provisioning/docker/environment.sh
    vhost_file_path=provisioning/docker/vhost.conf.tpl
    if [ -f "$environment_file_path" ]; then
      remove "$tmpdir" "$(grealpath "$environment_file_path")"
    fi
    if [ -f "$vhost_file_path" ]; then
      remove "$tmpdir" "$(grealpath "$vhost_file_path")"
    fi
    git checkout -- .
    if [ -f "$environment_file_path" ]; then
      restore "$tmpdir" "$(dirname "$environment_file_path")" "$(basename "$environment_file_path")"
    fi
    if [ -f "$vhost_file_path" ]; then
      restore "$tmpdir" "$(dirname "$vhost_file_path")" "$(basename "$vhost_file_path")"
    fi
    rm -rf "$tmpdir"
  fi
}

main "$1"
