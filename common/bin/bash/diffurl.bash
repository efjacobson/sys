#!/usr/bin/env bash

if [ -z "$2" ]; then
  echo "diff what bro?"
else
  grc diff <(curl -s "$1") <(curl -s "$2")
fi
