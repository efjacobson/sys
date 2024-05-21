#!/usr/bin/env bash

me=$(whoami)
sshfs Geriatrix@192.168.1.100:D:/ "/home/$me/mnt/d" -o "IdentityFile=/home/$me/.ssh/MountainPrime_id_ed25519"
