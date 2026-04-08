export EDITOR=nvim
export MANPAGER="nvim +Man!"
export HISTCONTROL=ignoreboth

export BAT_STYLE=plain
export BAT_THEME=ansi

if [[ -d "$HOME/.bin" ]]; then
  export PATH="$HOME/.bin:$PATH"
fi

if [[ -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

if [[ -d "$HOME/.config/composer/vendor/bin" ]]; then
  export PATH="$HOME/.config/composer/vendor/bin:$PATH"
fi

SSH_KEY="$HOME/.ssh/github"
SSH_ENV="$HOME/.ssh/agent.env"

start_ssh_agent() {
  eval "$(ssh-agent -s)" &>/dev/null

  echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >"$SSH_ENV"
  echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>"$SSH_ENV"

  if [[ -f "$SSH_KEY" ]]; then
    ssh-add "$SSH_KEY" &>/dev/null
  fi
}

if [[ -f "$SSH_ENV" ]]; then
  # shellcheck source=/dev/null
  source "$SSH_ENV" &>/dev/null
fi

if ! ssh-add -l &>/dev/null; then
  if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    start_ssh_agent
  fi
fi

bind "set completion-ignore-case on"

shopt -s histappend

alias ff="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias ls="eza --all --group-directories-first"
alias lt="eza --tree --all --group-directories-first"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

eval "$(fzf --bash)"
eval "$(mise activate bash)"
eval "$(starship init bash)"
