#! /bin/bash

# code -r "$@"

do_open () {
    # osascript -e "quit app \"PhpStorm\""
    # while pgrep -q phpstorm; do
    #     sleep 1
    # done
    open -na "PhpStorm.app" --args "${dir}" "${file}"
}

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
    do_open
    exit
fi

file="${last}"
dir=$(dirname "$(realpath "${file}")")
while ! find "${dir}" -maxdepth 1 -name '.git' -type d | grep -q '.git'; do
    dir=$(dirname "$(realpath "${dir}")")
    if [ "${dir}" = '/' ]; then
        file=
        do_open
        exit
    fi
done

do_open