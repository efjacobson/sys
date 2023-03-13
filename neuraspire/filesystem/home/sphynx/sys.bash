#! /bin/bash

if [ "$EUID" -ne 0 ]; then
  echo 'run as root'
  exit 1
fi

if [ '/home' != "$(dirname "$(pwd)")" ]; then
  echo 'run from your home dir'
  exit 1
fi

user="$(basename "$(pwd)")"

_fzf() {
  if [ ! -d /home/"$user"/._/dev/git/junegunn ]; then
    mkdir -p /home/"$user"/._/dev/git/junegunn
    chown "$user":"$user" -R /home/"$user"/._/dev/git/junegunn
  fi
  if [ ! -d  /home/"$user"/._/dev/git/junegunn/fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git /home/"$user"/._/dev/git/junegunn/fzf
    chown "$user":"$user" -R /home/"$user"/._/dev/git/junegunn/fzf
  fi
  if [ -x "$(command -v fzf)" ]; then
    if [ "$1" != 'update' ]; then
      printf '\ninstalling fzf...\n...already installed\n'
      return
    fi
    printf '\nupdating fzf...\n'
    pushd /home/"$user"/._/dev/git/junegunn/fzf
    git pull
    popd
  else
    sudo -u "$user" /home/"$user"/._/dev/git/junegunn/fzf/install
  fi
}

_zoxide() {
  if [ ! -x "$(command -v zoxide)" ]; then
    first=true
  fi
  _install 'zoxide'
  if [ first ] && [ -x "$(command -v zoxide)" ]; then
    cat << 'EOF' >> /home/"$user"/.zshrc

eval "$(zoxide init zsh)"
EOF
  fi
}

_update() {
  echo 'checking last update time...'
  updated_at="$(yq -r '.updated_at' /home/"$user"/._/sys/state.yaml)"
  now="$(date +'%s')"
  timer=$((24 * 60 * 60))
  if [ $((now - updated_at)) -gt "$timer" ]; then
    echo 'updating and upgrading with pamac and friends...'
    pamac update -a
    pamac upgrade -a
    _fzf 'update'
    tmp="$(mktemp)"
    yq -Y --argjson now $((now)) '.updated_at = $now' /home/"$user"/._/sys/state.yaml >"$tmp" && mv "$tmp" /home/"$user"/._/sys/state.yaml
    chown "$user":"$user" /home/"$user"/._/sys/state.yaml
  fi
}

_install() {
  if [ 'fzf' == "$1" ]; then
    _fzf
    return
  fi
  printf '\ninstalling %s...\n' "$1"
  pacman -Qi "$1" &>/dev/null
  if [ "$?" == '0' ]; then
    echo "...already installed"
  else
    _update
    echo "$(date +\'%s.%N\'): $1 (sys._install)" >>/etc/pacman.d/.log
    pamac install "$1"
  fi
}

_build() {
  printf '\nbuilding %s...\n' "$1"
  pacman -Qi "$1" &>/dev/null
  if [ "$?" == '0' ]; then
    echo "...already built"
  else
    _update
    echo "$(date +\'%s.%N\'): $1 (sys._build)" >>/etc/pacman.d/.log
    pamac build "$1"
  fi
}

_bak() {
  mirrordir="/home/$user/._/bak/filesystem/$(realpath "$(dirname "$1")")"
  if [ -e "$mirrordir/$(basename "$1").bak" ]; then
    return
  fi
  if [ ! -d "$mirrordir" ]; then
    mkdir -p "$mirrordir"
    chown "$user":"$user" "$mirrordir"
  fi
  cp -n "$1" "$mirrordir/$(basename "$1").bak"
  chmod 000 "$mirrordir/$(basename "$1").bak"
}

_first_run() {
  if [ -d /home/"$user"/._ ]; then
    return
  fi

    mkdir -p /home/"$user"/._/sys
    mkdir -p /home/"$user"/._/bak/filesystem
    chown "$user":"$user" /home/"$user"/._/bak

    if [ ! -d /etc/pacman.d/hooks ]; then
      mkdir -p /etc/pacman.d/hooks
    fi

    if [ ! -f /etc/pacman.d/hooks/99-install.hook ]; then
    cat << 'EOF' > /etc/pacman.d/hooks/99-install.hook
[Trigger]
Type = Package
Operation = Install
Target = *

[Action]
When = PostTransaction
Exec=/bin/sh -c 'while read -r target; do echo "$(date +\'%s.%N\'): $target" >>/etc/pacman.d/.log; done'
NeedsTargets
EOF
    fi

    ln -s /etc/pacman.d/.log /home/"$user"/._/sys/.pacman.log

    if [ ! -f /etc/pacman.conf.bak ]; then
      cp /etc/pacman.conf /etc/pacman.conf.bak
    fi
    sed -i 's/#HookDir/HookDir /' /etc/pacman.conf

    pamac update
    pamac upgrade
    _install yq

    yq -Y '.' <<<'{"updated_at":'"$(date +'%s')"'}' >/home/"$user"/._/sys/state.yaml

    chown "$user":"$user" -R /home/"$user"/._

    _setup_omv
}

_setup_omv() {
  if [ -f "/home/$user/._/.credentials/omv" ]; then
    return
  fi
  while true; do
    read -n 1 -r -p "setup omv? (y/N): " answer
    case "$answer" in
    Y | y)
      if [ ! -d /omv ]; then
        mkdir /omv
      fi
      chown "$user":"$user" -R /omv
      if [ ! -f "/home/$user/._/.credentials" ]; then
        mkdir -p "/home/$user/._/.credentials"
      fi
      echo "username=$user" >"/home/$user/._/.credentials/omv"
      read -s -p "enter password for $user for omv: " password
      echo "password=$password" >>"/home/$user/._/.credentials/omv"
      if [ ! -f /etc/fstab.bak ]; then
        cp /etc/fstab /etc/fstab.bak
      fi
      echo "//192.168.1.100/smb /omv cifs rw,user,credentials=/home/$user/._/.credentials/omv,noauto,_netdev 0 0" >>/etc/fstab
      chown "$user":"$user" -R /home/"$user"/._/.credentials
      systemctl daemon-reload
      break
      ;;
    *)
      break
      ;;
    esac
  done
}

_set_mac_address() {
  name='"$(hostname)"'
  mac=
  while [ -n "$name" ]; do
    if [ -n "$mac" ]; then
      mac+=':'
    fi
    trimmed="$(echo "$name" | sed s/.//)"
    char=${name:0:1}
    hex="$(echo -n "$char" | od -An -tx2)"
    dub=${hex: -2}
    mac+="$(echo "$dub" | tr '[:lower:]' '[:upper:]')"
    if [ 17 -eq ${#mac} ]; then
      break
    fi
    name=$trimmed
  done

  while [ 17 -gt ${#mac} ]; do
    mac+=':00'
  done

  _install macchanger
  eval "macchanger --mac=$mac"
}

_zshrc() {
  # todo: need to consolidate this, fzf, and zoxide edits to the file
  if [ ! -f /home/"$user"/.zshrc.original ]; then
    cp /home/"$user"/.zshrc /home/"$user"/.zshrc.original
  fi
  _bak /home/"$user"/.zshrc.original
  chmod 000 /home/"$user"/.zshrc.original
  cp /home/"$user"/.zshrc.original /home/"$user"/.zshrc
  chmod 644 /home/"$user"/.zshrc

  cat << 'EOF' >> /home/"$user"/.zshrc

alias c='clear'
EOF
}

packages=(ripgrep code bat thunderbird xsel jc ffmpeg freecad fzf virt-viewer libreoffice ledger-live-bin mediainfo)
aurs=(authy brother-mfc-l2710dw)

_main() {
  # _set_mac_address
  _zshrc
  _first_run

  for package in "${packages[@]}"; do
    _install "$package"
  done

  for aur in "${aurs[@]}"; do
    _build "$aur"
  done

  _zoxide
}

_main
