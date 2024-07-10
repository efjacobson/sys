#! /usr/bin/env bash
set -e

count="${1}"
if [[ -z "${count}" ]]; then
  count=1
fi

git reset --soft "HEAD~${count}"
