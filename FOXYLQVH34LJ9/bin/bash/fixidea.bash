#!/usr/bin/env bash

if ! [ -e "$(pwd)/composer.json" ]; then
    echo "no php here!"
    exit 1
fi

idea="$(pwd)/.idea"

if ! [ -e "${idea}" ]; then
    echo "no .idea here!"
    exit 0
fi

file="${idea}/$(basename "$(pwd)").iml"
if ! [ -f "${file}" ]; then
    echo "no .iml here!"
    exit 1
fi

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
    self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
    self="$(readlink "${self}")"
    [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"
selfdir=$(dirname "${self}")
pydir="$(dirname "${selfdir}")/python"
cd "${pydir}/fixidea" || exit 1

# cd '/Users/eric.jacobson/_/dev/sandbox/python' || exit 1
pipenv run ./main.py "${file}"
# node ./main.mjs "${file}"