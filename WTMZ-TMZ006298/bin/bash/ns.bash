#! /usr/bin/env bash
set -e

source "$(brew --prefix nvm)"/nvm.sh
nvm use

[ ! -d node_modules ] && npm install

npm start
