#! /bin/bash

if [ -z "${1}" ]; then
  echo "you must enter a branch name"
  exit 1
fi

git fetch
git checkout "${1}"
git pull origin "${1}"