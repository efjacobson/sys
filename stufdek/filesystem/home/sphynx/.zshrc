# Use powerline
USE_POWERLINE="true"

# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi

# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

MAX_INT=0
for ((x=1,y=1; x<<=y; y<<=1))
do
    if ((x>0))
    then
        MAX_INT=$x
        continue
    fi

    if (((x=~x)>0))
    then
        MAX_INT=$x
    fi
    break
done

HISTSIZE=$MAX_INT
SAVEHIST=$MAX_INT

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

[ -f "/home/$(whoami)/_/.env" ] && source "/home/$(whoami)/_/.env"

! [ -e "/home/$(whoami)/_/bin" ] && mkdir -p "/home/$(whoami)/_/bin"
PATH="/home/$(whoami)/_/bin:${PATH}"

if [ -d "/home/$(whoami)/.cargo/bin" ]; then
  PATH="${PATH}:/home/$(whoami)/.cargo/bin"
  command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"

  if command -v imdb-rename >/dev/null 2>&1; then
    for dir in 'data' 'index'; do
      if ! [ -e "/home/$(whoami)/.cache/imdb-rename/${dir}" ]; then
        mkdir -p "/home/$(whoami)/.cache/imdb-rename/${dir}"
      fi
      ucdir="$(tr '[:lower:]' '[:upper:]' <<< "${dir}")"
      export "IMDB_RENAME_${ucdir}_DIR"="/home/$(whoami)/.cache/imdb-rename/${dir}"
    done
  fi
fi

[ -f /usr/share/zsh/plugins/forgit/forgit.plugin.zsh ] && source /usr/share/zsh/plugins/forgit/forgit.plugin.zsh
[ -f /usr/share/zsh/plugins/forgit/completions/git-forgit.zsh ] && source /usr/share/zsh/plugins/forgit/completions/git-forgit.zsh

if [ -f "/home/$(whoami)/.fzf.zsh" ]; then
  source "/home/$(whoami)/.fzf.zsh"

  # morhetz/gruvbox
  export FZF_DEFAULT_OPTS='--color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'
fi

export PATH="${PATH}"

# must come at end
eval "$(zoxide init zsh)"
