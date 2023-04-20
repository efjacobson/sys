#! /bin/bash

cut -d ' ' -f 1 <<<"$(ls -la "$(which "$1")" | rev)" | rev
