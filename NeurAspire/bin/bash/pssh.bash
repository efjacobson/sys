#! /bin/bash

[ -z "$1" ] && echo 'where to?' && exit

ssh "$(hostname)@$1"
