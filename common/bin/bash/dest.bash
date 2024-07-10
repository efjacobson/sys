#! /usr/bin/env bash
set -e

cut -d ' ' -f 1 <<<"$(ls -la "$(which "$1")" | rev)" | rev
