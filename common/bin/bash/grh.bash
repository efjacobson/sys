#! /usr/bin/env bash
set -e

if [ -z "${1}" ]; then
    git reset HEAD -- .
else
    git reset HEAD "${1}"
fi
