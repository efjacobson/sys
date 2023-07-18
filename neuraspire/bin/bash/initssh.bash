#! /bin/bash

return_val=
for item in /home/"$(whoami)"/.ssh/*; do
    key="$(basename "$item")"
    if [[ "$key" =~ (known_hosts|config|.+\.pub$) ]]; then
        continue
    else
        return_val="$(keychain -q --agents ssh --eval "$item")"
    fi
done

echo "$return_val"
