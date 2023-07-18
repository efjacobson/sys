#! /bin/bash

apply_changes=false
nuclear=false
running=true

for opt in "$@"; do
  case ${opt} in
  --apply_changes)
    apply_changes=true
    ;;
  -a)
    apply_changes=true
    ;;
  --nuclear)
    nuclear=true
    ;;
  -n)
    nuclear=true
    ;;
  --help)
    display_help
    exit
    ;;
  *)
    display_help
    exit
    ;;
  esac
done

main() {
  if (! docker stats --no-stream); then
    running=false
  fi

  if [ false == $apply_changes ]; then
    if [ true == $running ]; then
      echo 'docker is running, use -a to stop'
    else
      echo 'docker is not running, use -a to start'
    fi
    exit 0
  fi

  if [ true == $running ]; then
    echo 'killing...'
    if [ true == $nuclear ]; then
      sudo sh -c 'pgrep docker | xargs kill'
    else
      pgrep docker | xargs kill
    fi
  else
    echo 'starting...'
    /Applications/Docker.app/Contents/MacOS/Docker\ Desktop.app/Contents/MacOS/Docker\ Desktop
  fi
}

main
