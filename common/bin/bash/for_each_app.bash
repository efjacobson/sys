#!/usr/bin/env bash

vendors=('tmz' 'toofab')
apps=('amp' 'api' 'feeds' 'share' 'web' 'pbjx' 'ncr')
extra=('tmz-ovp')

do_echo() {
    echo "https://github.com/tmz-apps/${1}/issues"
}

for vendor in "${vendors[@]}"; do
 for app in "${apps[@]}"; do
  do_echo "${vendor}-${app}"
 done
done

for extra in "${extra[@]}"; do
  do_echo "${extra}"
done