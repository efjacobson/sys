#!/usr/bin/env bash

if [ -z "${1}" ]; then
  git log
else
  git log "-${1}"
fi
