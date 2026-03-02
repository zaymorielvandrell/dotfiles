#!/usr/bin/env bash

set -euo pipefail

DOTFILES_CMD="collect"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_HOME_DIR="$REPO_ROOT_DIR/home"
SYSTEM_HOME_DIR="$HOME"

readonly DOTFILES_CMD
readonly SCRIPT_DIR
readonly REPO_ROOT_DIR
readonly REPO_HOME_DIR
readonly SYSTEM_HOME_DIR

# shellcheck source=bin/_lib.sh
source "$REPO_ROOT_DIR/bin/_lib.sh"

# shellcheck source=bin/_tracked_paths.sh
source "$REPO_ROOT_DIR/bin/_tracked_paths.sh"

copy_file() {
  local relative_path="$1"
  local system_path="$SYSTEM_HOME_DIR/$relative_path"
  local repo_path="$REPO_HOME_DIR/$relative_path"

  if [[ ! -f "$system_path" ]]; then
    log_warn "Skip (missing in system): $relative_path"
    return 0
  fi

  if [[ -e "$repo_path" && -d "$repo_path" ]]; then
    fatal "Destination is a directory (expected file): $repo_path"
  fi

  mkdir -p "$(dirname "$repo_path")"
  cp -a "$system_path" "$repo_path"
  log_info "Copied file: $relative_path"
}

copy_dir() {
  local relative_path="$1"
  local system_path="$SYSTEM_HOME_DIR/$relative_path"
  local repo_path="$REPO_HOME_DIR/$relative_path"

  if [[ ! -d "$system_path" ]]; then
    log_warn "Skip (missing in system): $relative_path"
    return 0
  fi

  if [[ -e "$repo_path" && ! -d "$repo_path" ]]; then
    fatal "Destination is not a directory: $repo_path"
  fi

  mkdir -p "$repo_path"
  rsync -a --delete "$system_path/" "$repo_path/"
  log_info "Synced dir: $relative_path"
}

main() {
  require_command rsync

  mkdir -p "$REPO_HOME_DIR"

  for relative_path in "${TRACKED_DIRS[@]}"; do
    copy_dir "$relative_path"
  done

  for relative_path in "${TRACKED_FILES[@]}"; do
    copy_file "$relative_path"
  done

  log_info "Done. Repo directory: $REPO_HOME_DIR"
}

main "$@"
