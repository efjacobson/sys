#! /usr/bin/env bash
set -e

dry_run=true
src="$1"
shift

for opt in "$@"; do
  case ${opt} in
  --hot)
    dry_run=false
    ;;
  *)
    echo 'bad argument'
    exit 1
    ;;
  esac
done

main() {
  if ! [ -d "$src" ]; then
    echo "nope, '$src' is not a directory"
  fi
  dir=$(realpath "$src")
  while IFS= read -r -d '' file; do
    dest="$dir/$(basename "$file")"
    if ! [ -f "$dest" ]; then
      if $dry_run; then
        echo "$(realpath "$file") => $dest"
      else
        mv "$file" "$dest"
      fi
    else
      echo "dupe! '$(realpath "$file")'"
    fi
  done <   <(find "$src" -type f -print0)
}

main "$@"
