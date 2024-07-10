#! /usr/bin/env bash
set -e

echo 75 > /sys/class/power_supply/BAT1/charge_control_end_threshold

five_minutes_in_seconds=$(( 5 * 60 ))

mountomv() {
  if ! ping -q -c 1 -i 5 192.168.1.100 > /dev/null 2>&1; then
    return
  fi

  for d in /home/*; do
    user="$(basename "$d")"
    break
  done

  runuser -u "${user}" -- mount "/home/${user}/mnt/omv"
}

nm-online -q -s -t "${five_minutes_in_seconds}" && nm-online -q -t "${five_minutes_in_seconds}" && mountomv
