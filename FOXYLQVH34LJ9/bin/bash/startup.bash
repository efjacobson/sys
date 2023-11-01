#! /bin/bash

smb='/Volumes/users-eric-jacobson'

open_obsidian() {
  if [ -z "${1}" ]; then
    delay=30
  else
    delay=60
  fi
  sleep "${delay}"
  if [ -e "${smb}" ]; then
    /usr/bin/open /Applications/Obsidian.app
  elif [ -z "${1}" ]; then
    (open_obsidian 'final' &) 
  fi
}

do_smb() {
  if [ -e "${smb}" ]; then
    /usr/bin/open /Applications/Obsidian.app
  else
    /usr/bin/open "smb://eric.jacobson@omv.mountainprime.lol"
    (open_obsidian &) 
  fi
}

unlock_sync() {
  local lockfile='/Users/eric.jacobson/_/dev/git/efjacobson/sys/FOXYLQVH34LJ9/bin/bash/sync.bash.lock'
  [ -e "${lockfile}" ] && rm "${lockfile}"
}

main() {
  unlock_sync
  do_smb
}

main
