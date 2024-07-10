#! /usr/bin/env bash
set -e

return_val=
for item in /home/"$(whoami)"/.ssh/*; do
    key="$(basename "$item")"
    if [[ "$key" =~ (known_hosts|config|.+\.pub$) ]]; then
        continue
    else
        return_val="$item $return_val"
    fi
done

echo "keychain --eval $return_val"
