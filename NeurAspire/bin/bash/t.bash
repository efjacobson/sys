#! /bin/bash

here=$(realpath "$0")
src=
while [ '' == "$src" ]; do
    here=$(dirname "$here")
    src=$(find "$here" -type f -name .tmux.session.0)
done
tmux new-session "tmux source-file $src"
