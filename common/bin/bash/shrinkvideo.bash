#!/usr/bin/env bash

ffmpeg -i "${1}" -vcodec libx265 "${1%.*}_sm.mp4"