#!/usr/bin/env bash

 git verify-commit "$(git log -1 --pretty=format:'%h')"