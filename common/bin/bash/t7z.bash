#! /bin/bash

timestamp=false
password=false
dest=
src=

for opt in "$@"; do
  case ${opt} in
  -t)
    timestamp=true
    ;;
  --timestamp)
    timestamp=true
    ;;
  -p)
    password=true
    ;;
  --password)
    password=true
    ;;
  --destination=*)
    dest=${opt#*=}
    ;;
  *)
    src="${opt}"
    ;;
  esac
done

main() {
  if [ '.tar.7z' == "${src: -7}" ]; then
    echo "enter password:"
    7z x "$src" -so | tar xf -
  else
    if [ -z "$dest" ]; then
      if ! $timestamp; then
        dest="$src.tar.7z"
      else
        dest="$src.$(date +%s).tar.7z"
      fi
    fi
    tar cf - "$src" | 7z a "$dest" -si "$($password && '-mhe=on -p')"
  fi
}

main
