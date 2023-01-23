#! /bin/bash

declare -A alpha
i=0
for char in $(echo 'abcdefghijklmnopqrstuvwxyz' | grep -o .); do
  i=$((i + 1))
  alpha[$char]=$i
done

val=1
for char in $(echo "$1" | grep -o .); do
  if [[ "$char" =~ [abcdefghijklmnopqrstuvwxyz] ]]; then
    val=$((val * "${alpha[$char]}"))
  fi
done

echo "$val"
