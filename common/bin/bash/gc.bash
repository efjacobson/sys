#! /bin/bash

if [ -z "$1" ]; then
  echo "what do you want to checkout?"
else
  git checkout "$@"
fi
