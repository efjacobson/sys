#! /bin/bash

if [ "$1" == "" ]; then
  git log
else
  git log -$1
fi
