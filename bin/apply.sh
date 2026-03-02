#!/usr/bin/env bash

set -euo pipefail

DOTFILES_CMD="apply"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_HOME_DIR="$REPO_ROOT_DIR/home"
SYSTEM_HOME_DIR="$HOME"
BACKUP_ROOT_DIR="$REPO_ROOT_DIR/.backup"
BACKUP_DIR="$BACKUP_ROOT_DIR/$(date +%Y%m%d-%H%M%S)"

readonly DOTFILES_CMD
readonly SCRIPT_DIR
readonly REPO_ROOT_DIR
readonly REPO_HOME_DIR
readonly SYSTEM_HOME_DIR
readonly BACKUP_ROOT_DIR
readonly BACKUP_DIR

# shellcheck source=bin/_lib.sh
source "$REPO_ROOT_DIR/bin/_lib.sh"

# shellcheck source=bin/_tracked_paths.sh
source "$REPO_ROOT_DIR/bin/_tracked_paths.sh"

backup_item() {
  local relative_path="$1"
  local system_path="$SYSTEM_HOME_DIR/$relative_path"
  local backup_path="$BACKUP_DIR/$relative_path"

  if [[ -e "$system_path" ]]; then
    mkdir -p "$(dirname "$backup_path")"
    cp -a "$system_path" "$backup_path"
    log_info "Backed up: $relative_path"
  fi
}

apply_file() {
  local relative_path="$1"
  local repo_path="$REPO_HOME_DIR/$relative_path"
  local system_path="$SYSTEM_HOME_DIR/$relative_path"

  if [[ ! -f "$repo_path" ]]; then
    log_warn "Skip (missing in repo): $relative_path"
    return 0
  fi

  if [[ -e "$system_path" && -d "$system_path" ]]; then
    fatal "Destination is a directory (expected file): $system_path"
  fi

  mkdir -p "$(dirname "$system_path")"
  cp -a "$repo_path" "$system_path"
  log_info "Copied file: $relative_path"
}

apply_dir() {
  local relative_path="$1"
  local repo_path="$REPO_HOME_DIR/$relative_path"
  local system_path="$SYSTEM_HOME_DIR/$relative_path"

  if [[ ! -d "$repo_path" ]]; then
    log_warn "Skip (missing in repo): $relative_path"
    return 0
  fi

  if [[ -e "$system_path" && ! -d "$system_path" ]]; then
    fatal "Destination is not a directory: $system_path"
  fi

  mkdir -p "$system_path"
  rsync -a --delete "$repo_path/" "$system_path/"
  log_info "Synced dir: $relative_path"
}

main() {
  require_command rsync

  [[ -d "$REPO_HOME_DIR" ]] || fatal "Missing repo home directory: $REPO_HOME_DIR"

  mkdir -p "$BACKUP_DIR"

  for relative_path in "${TRACKED_DIRS[@]}"; do
    backup_item "$relative_path"
  done

  for relative_path in "${TRACKED_FILES[@]}"; do
    backup_item "$relative_path"
  done

  for relative_path in "${TRACKED_DIRS[@]}"; do
    apply_dir "$relative_path"
  done

  for relative_path in "${TRACKED_FILES[@]}"; do
    apply_file "$relative_path"
  done

  log_info "Done. Backup directory: $BACKUP_DIR"
}

main "$@"
