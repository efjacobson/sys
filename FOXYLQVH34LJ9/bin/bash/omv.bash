#! /usr/bin/env bash
set -e

smb='/Volumes/users-eric-jacobson'

open_obsidian() {
  sleep 19
  if [ -e "${smb}" ]; then
    /usr/bin/open /Applications/Obsidian.app
  fi
}

main() {
  if [ -e "${smb}" ]; then
    exit
  fi

  /usr/bin/open "smb://eric.jacobson@omv.mountainprime.lol"

  sleep 11

  (open_obsidian &)
}

main
