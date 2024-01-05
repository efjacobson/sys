#!/bin/bash

# --- native options ---
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt checkjobs
setopt hup
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.
setopt histignoredups
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.

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

# --- powerlevel10k ---
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

# --- fnm ---
[ -f ~/.fnm/fnm.zsh ] && source ~/.fnm/fnm.zsh
export PATH="$HOME/Library/Application Support/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# --- fzf ---
if [ -f ~/.fzf.zsh ] || [ -L ~/.fzf.zsh ]; then
  source ~/.fzf.zsh # put your options in this file, not here (just to keep it simple)
fi

# --- aliases ---
alias c='clear'
alias e='exit'
alias co='code -r'
alias gs='git status'
alias gb='git branch'
alias gf='git fetch'
alias ls='gls --color=auto --human-readable --group-directories-first --classify --time-style=+"" -lA'

# --- pyenv ---
export PYENV_ROOT="${HOME}/.pyenv"
command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)"

# --- rbenv ---
eval "$(rbenv init - zsh)"

# --- ...rest ---
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"

source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=166'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PATH="$HOME/_/bin:$PATH"

# --- must be antepenultimate ---
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# --- must be penultimate ---
source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
export HISTORY_SUBSTRING_SEARCH_FUZZY=1
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# --- must be ultimate ---
_ZO_EXCLUDE_DIRS="${HOME}:${HOME}/_/dev/git/tmz-apps"
eval "$(zoxide init zsh)"