#! /bin/bash

main() {
  src="$1"

  if [ '.tar.7z' == "${src: -7}" ]; then
    echo "enter password:"
    7z x "$src" -so | tar xf -
  else
    tar cf - "$src" | 7z a "$src.tar.7z" -p -mhe=on -si
  fi
}

main "$1"
