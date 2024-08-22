# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
