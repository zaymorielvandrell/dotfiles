# shellcheck shell=bash

export EDITOR=nvim
export MANPAGER="nvim +Man!"
export HISTCONTROL=ignoreboth

export BAT_STYLE=plain
export BAT_THEME=ansi

if [[ -d "$HOME/.bin" ]]; then
  export PATH="$HOME/.bin:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d "$HOME/.config/composer/vendor/bin" ]]; then
  export PATH="$HOME/.config/composer/vendor/bin:$PATH"
fi

SSH_KEYS=(
  "$HOME/.ssh/github"
  "$HOME/.ssh/sveikalabs"
)
SSH_ENV="$HOME/.ssh/agent.env"

start_ssh_agent() {
  eval "$(ssh-agent -s)" &>/dev/null

  echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >"$SSH_ENV"
  echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>"$SSH_ENV"

  for key in "${SSH_KEYS[@]}"; do
    if [[ -f "$key" ]]; then
      ssh-add "$key" &>/dev/null
    fi
  done
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

alias v="nvim"
alias c="flatpak run com.visualstudio.code"
alias z="flatpak run --env=ZED_FLATPAK_NO_ESCAPE=1 dev.zed.Zed"

alias lg="lazygit"
alias ld="lazydocker"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

eval "$(fzf --bash)"
eval "$(mise activate bash)"
eval "$(starship init bash)"
