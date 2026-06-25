#!/bin/bash

log_info() {
  printf "[%s] %s\n" "${DOTFILES_CMD:-dotfiles}" "$*"
}

log_warn() {
  printf "[%s] WARN: %s\n" "${DOTFILES_CMD:-dotfiles}" "$*"
}

log_error() {
  printf "[%s] ERROR: %s\n" "${DOTFILES_CMD:-dotfiles}" "$*" >&2
}

fatal() {
  log_error "$*"
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fatal "Missing command: $1"
}

require_commands() {
  local command_name

  for command_name in "$@"; do
    require_command "$command_name"
  done
}

# shellcheck disable=SC2034
init_repo_paths() {
  local script_path="$1"

  SCRIPT_DIR="$(cd "$(dirname "$script_path")" && pwd)"
  REPO_ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  REPO_HOME_DIR="${REPO_ROOT_DIR}/home"
  SYSTEM_HOME_DIR="$HOME"
}
