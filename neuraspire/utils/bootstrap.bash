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

_drawio() {
  appdir="/home/$user/._/app"
  if [ ! -d "$appdir" ]; then
    mkdir -p "$appdir"
    chown "$user":"$user" -R "$appdir"
  fi
  if [ ! -f "$appdir/drawio-x86_64-20.8.16.AppImage" ]; then
    pushd "$appdir" || exit
    wget 'https://github.com/jgraph/drawio-desktop/releases/download/v20.8.16/drawio-x86_64-20.8.16.AppImage'
    chown "$user":"$user" -R "$appdir"
    popd || exit
  fi
}

_has_fzf=false
_fzf() {
  junegunn="/home/$user/._/dev/git/junegunn"
  if [ ! -d "$junegunn" ]; then
    mkdir -p "$junegunn"
    chown "$user":"$user" -R "$junegunn"
  fi
  if [ ! -d  "$junegunn/fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$junegunn/fzf"
    chown "$user":"$user" -R "$junegunn/fzf"
    printf '\ninstalling fzf...\n'
    sudo -u "$user" "$junegunn/fzf"/install
    printf '\n...done\n'
  elif [ "$1" != 'update' ]; then
    printf '\nupdating fzf...\n'
    pushd "$junegunn/fzf" || exit
    git pull
    popd || exit
    printf '\n...done\n'
  else
    printf '\ninstalling fzf...\n...already installed\n'
  fi
  _has_fzf=true
}

_has_zoxide=false
_zoxide() {
  _install 'zoxide'
  _has_zoxide=true
}

_updated=false
_update() {
  if $_updated; then
    return
  fi
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
    if [ ! -f /home/"$user"/._/sys/state.yaml ]; then
      touch /home/"$user"/._/sys/state.yaml
    fi
    yq -Y --argjson now $((now)) '.updated_at = $now' /home/"$user"/._/sys/state.yaml >"$tmp" && mv "$tmp" /home/"$user"/._/sys/state.yaml
    chown "$user":"$user" /home/"$user"/._/sys/state.yaml
  else
    echo '...skipping update as it has already been done in the last 24 hours'
  fi
  _updated=true
}

_install() {
  if [ 'fzf' == "$1" ]; then
    _fzf
    return
  fi
  if [ 'drawio' == "$1" ]; then
    _drawio
    return
  fi
  printf '\ninstalling %s...\n' "$1"
  pacman -Qi "$1" &>/dev/null
  if [ "$?" == '0' ]; then
    echo "...already installed"
  else
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
    pamac install yq
    pamac install cifs-utils

    if [ ! -f /home/"$user"/._/sys/state.yaml ]; then
      touch /home/"$user"/._/sys/state.yaml
    fi
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

_zshrc() {
  if [ ! -f /home/"$user"/.zshrc.original ]; then
    cp /home/"$user"/.zshrc /home/"$user"/.zshrc.original
  fi
  _bak /home/"$user"/.zshrc.original
  chmod 000 /home/"$user"/.zshrc.original
  cp /home/"$user"/.zshrc.original /home/"$user"/.zshrc
  chmod 644 /home/"$user"/.zshrc
  chown "$user:$user" /home/"$user"/.fzf.zsh

  if $_has_zoxide; then
    cat << 'EOF' >> /home/"$user"/.zshrc

eval "$(zoxide init zsh)"

EOF
  fi

  if $_has_fzf; then
    cat << 'EOF' >> /home/"$user"/.zshrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

EOF

  rm /home/"$user"/.fzf.zsh
  cat << 'EOF' >> /home/"$user"/.fzf.zsh

# Setup fzf
# ---------
if [[ ! "$PATH" == */home/"$(whoami)"/._/dev/git/junegunn/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/"$(whoami)"/._/dev/git/junegunn/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/"$(whoami)"/._/dev/git/junegunn/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/"$(whoami)"/._/dev/git/junegunn/fzf/shell/key-bindings.zsh"

EOF

  fi

  cat << 'EOF' >> /home/"$user"/.zshrc

export PATH=/home/"$(whoami)"/._/bin:$PATH

HISTFILE=~/.zshistory
HISTSIZE=1000000
SAVEHIST=1000000

setopt notify
setopt nomatch
setopt extendedglob
setopt autocd
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE

unsetopt beep

alias c='clear'
alias gf='git fetch'
alias gs='git status'
alias gd='git diff'
alias ls='ls --color=auto --human-readable --group-directories-first --classify --time-style=+"" -lA'

if [ -z "$SSH_AGENT_PID" ]; then
  for item in /home/"$(whoami)"/.ssh/*; do
    key="$(basename "$item")"
    if [[ "$key" =~ (known_hosts|config|.+\.pub$) ]]; then
      continue
    else
      eval "$(keychain -q --agents ssh --eval "$key")"
    fi
  done
fi

source /usr/share/nvm/init-nvm.sh

auto_nvmrc() {
  if [[ $PWD == $PREV_PWD ]]; then
    return
  fi

  if [[ "$PWD" =~ "$PREV_PWD" && ! -f ".nvmrc" ]]; then
    return
  fi

  PREV_PWD=$PWD
  if [[ -f ".nvmrc" ]]; then
    nvm use
    NVM_DIRTY=true
  elif [[ $NVM_DIRTY = true ]]; then
    nvm use default
    NVM_DIRTY=false
  fi
}

chpwd_functions+=( auto_nvmrc )

EOF
}

_main() {
  _first_run
  _update

  for package in "${packages[@]}"; do
    _install "$package"
  done

  for aur in "${aurs[@]}"; do
    _build "$aur"
  done

  for c in "${cargos[@]}"; do
    sudo -u "$user" cargo install "$c"
  done

  for p in "${pips[@]}"; do
    sudo -u "$user" pip3 install --upgrade "$p"
  done

  if [ -x "$(command -v snap)" ]; then
    for s in "${snaps[@]}"; do
        snap install "$s"
    done
  else
    echo 'snap is not installed!'
  fi

  _zoxide

  pamac remove -o

  _zshrc
}

cargos=(
  imdb-rename
)

pips=(
  # gimme-aws-creds
)

aurs=(
  dupeguru
  authy
  brother-mfc-l2710dw
  qdirstat
)

snaps=(
  mqtt-explorer
  spotify
)

packages=(
  aws-cli-v2
  base-devel
  bat
  bind
  clonezilla
  code
  drawio
  ffmpeg
  freecad
  fzf
  glances
  gparted
  jc
  keychain
  krdc
  krename
  krfb
  ledger-live-bin
  libreoffice
  mediainfo
  nodejs
  nvm
  nvm
  pkgconf
  qbittorrent
  qmk
  ripgrep
  rust
  shellcheck
  snapd
  sweethome3d
  syncthing
  thunderbird
  tldr
  traceroute
  virt-viewer
  vivaldi
  vlc
  wavemon
  whois
  wireshark-qt
  xsel
  zbar
  zip
)

_main
