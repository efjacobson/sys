# Use powerline
USE_POWERLINE="true"

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi

# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

command -v fzf &>/dev/null && {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.bash && echo 'sourced ~/.fzf.zsh'
  [ -f ~/.fzf.completion.zsh ] && source ~/.fzf.completion.zsh && echo 'sourced ~/.fzf.completion.zsh'
  [ -f ~/.fzf.key-bindings.zsh ] && source ~/.fzf.key-bindings.zsh && echo 'sourced ~/.fzf.key-bindings.zsh'
  export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {} --theme gruvbox-dark'"
}

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

setopt histignoredups

alias c="clear"
