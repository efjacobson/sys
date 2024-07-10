#! /usr/bin/env bash
set -e

 git verify-commit "$(git log -1 --pretty=format:'%h')"