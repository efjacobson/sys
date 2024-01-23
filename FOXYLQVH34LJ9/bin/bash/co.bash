#! /bin/bash

# code -r "$@"

last=
for arg in "$@"; do
    last=$arg
done

if [ -d "${last}" ]; then
    dir="${last}"
elif [ -z "${last}" ]; then
    dir='./'
fi

if [ -n "${dir}" ]; then
    code -r "${dir}"
    exit
fi

file="${last}"
dir=$(dirname "$(realpath "${file}")")
while ! find "${dir}" -maxdepth 1 -name '.git' -type d | grep -q '.git'; do
    dir=$(dirname "$(realpath "${dir}")")
    if [ "${dir}" = '/' ]; then
        code -r "${file}"
        exit
    fi
done

code -r "${dir}" "${file}"