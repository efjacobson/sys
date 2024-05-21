#!/usr/bin/env bash

if [[ -f .nvmrc ]]; then
	source "$(brew --prefix nvm)"/nvm.sh
	nvm use
fi

npm install
