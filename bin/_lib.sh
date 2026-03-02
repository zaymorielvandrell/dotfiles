#!/usr/bin/env bash

log_info() {
  printf '[%s] %s\n' "${DOTFILES_CMD:-dotfiles}" "$*"
}

log_warn() {
  printf '[%s] WARN: %s\n' "${DOTFILES_CMD:-dotfiles}" "$*"
}

log_error() {
  printf '[%s] ERROR: %s\n' "${DOTFILES_CMD:-dotfiles}" "$*" >&2
}

fatal() {
  log_error "$*"
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fatal "Missing command: $1"
}
