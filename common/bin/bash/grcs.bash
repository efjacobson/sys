#!/usr/bin/env bash

count="${1}"
if [[ -z "${count}" ]]; then
  echo 'provde the number of commits you want to revert'
  exit 1
fi

if ! [[ "${count}" =~ [1-9]([0-9])? ]]; then
  echo "invalid number: ${count}"
  exit 1
fi

index=0

revert () {
  git revert --no-edit "HEAD~${index}" || exit 1
  index=$((index + 2))
  count=$((count - 1))
}

revert
while [[ "${count}" -gt 0 ]]; do
  revert
done
