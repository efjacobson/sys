#! /bin/bash

mount_point="$HOME/mnt/MountainPrime/d"
if [ "$(ls -A "$mount_point")" ]; then
  sudo umount "$mount_point"
else
  sudo mount -t cifs //192.168.1.100/d "$mount_point" -o rw,vers=3.0,uid=$(id -u),username=$(hostname)
fi
