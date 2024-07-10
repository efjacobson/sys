#! /usr/bin/env bash
set -e

src="$1"

while IFS= read -r -d '' file; do
  if [ -d "$file" ]; then
    continue
  fi
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  dir="$(dirname "$file")/$filename"
  mkdir "$dir"
  mv "$file" "$dir"/
done <   <(find "$src" -maxdepth 1 -type f -print0)