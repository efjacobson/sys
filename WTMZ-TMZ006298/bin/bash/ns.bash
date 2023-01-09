#! /bin/bash

source "$(brew --prefix nvm)"/nvm.sh
nvm use

[ ! -d node_modules ] && npm install

npm start
