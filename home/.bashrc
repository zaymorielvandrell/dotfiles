export EDITOR=nvim
export MANPAGER="nvim +Man!"
export HISTCONTROL=ignoreboth

export BAT_STYLE=plain
export BAT_THEME=ansi

if [[ -d "$HOME/.bin" ]]; then
  export PATH="$HOME/.bin:$PATH"
fi

if [[ -d "$HOME/.config/composer/vendor/bin" ]]; then
  export PATH="$HOME/.config/composer/vendor/bin:$PATH"
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
