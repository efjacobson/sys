# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

zle     -N            fzf-cd-widget
bindkey -M emacs '^J' fzf-cd-widget
bindkey -M vicmd '^J' fzf-cd-widget
bindkey -M viins '^J' fzf-cd-widget

# Options
# ------------
[ -f /opt/homebrew/opt/forgit/share/forgit/forgit.plugin.zsh ] && source /opt/homebrew/opt/forgit/share/forgit/forgit.plugin.zsh

export FZF_DEFAULT_OPTS="
  --preview-window wrap
  --bind 'ctrl-/:toggle-preview'
  --color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
  --height=66%
  --layout=reverse
  --info=inline
  --border
  --margin=1
  --padding=1"

export FZF_CTRL_T_OPTS="
  ${FZF_DEFAULT_OPTS}
  --preview '[ -f {} ] && bat -n --color=always {}'"

export FZF_CTRL_R_OPTS="
  ${FZF_DEFAULT_OPTS}
  --preview 'echo {}'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_ALT_C_OPTS="
  ${FZF_DEFAULT_OPTS}
  --preview 'tree -C {}'"
