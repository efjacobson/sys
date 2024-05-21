#!/usr/bin/env bash

undo_at_file="$(mktemp)"
delay=10

revert () {
  sleep $delay
  if [ ! -f "${undo_at_file}" ]; then
    return
  fi
  undo_at="$(cat "${undo_at_file}")"
  if [ -z "${undo_at}" ]; then
    return
  fi
  if [ "$(date +%s)" -lt "${undo_at}" ]; then
    (revert &)
  else
    brightnessctl -d asus::kbd_backlight s 0 > /dev/null 2>&1
  fi
}

main () {
  (( $(date +%s) + delay )) > "${undo_at_file}"
  if [ 0 -ne "$(brightnessctl -d asus::kbd_backlight g)" ]; then
    return
  fi
  brightnessctl -d asus::kbd_backlight s 1 > /dev/null 2>&1
  (revert &)
}

while read -rs _k; do unset _k
  (main &)
done < <(logkeys --no-daemon -s -o -)

