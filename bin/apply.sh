#!/bin/bash

set -euo pipefail

# shellcheck disable=SC2034
DOTFILES_CMD="apply"

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"
init_repo_paths "${BASH_SOURCE[0]}"

source "${REPO_ROOT_DIR}/bin/_tracked_paths.sh"

BACKUP_ROOT_DIR="${REPO_ROOT_DIR}/.backup"
BACKUP_DIR=""

BACKED_UP_COUNT=0
COPIED_FILE_COUNT=0
SYNCED_DIR_COUNT=0
SKIPPED_COUNT=0

backup_item() {
  local relative_path="$1"
  local system_path="${SYSTEM_HOME_DIR}/${relative_path}"
  local backup_path="${BACKUP_DIR}/${relative_path}"

  if [[ ! -e "$system_path" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$backup_path")"
  cp -a "$system_path" "$backup_path"
  log_info "Backed up: ${relative_path}"
  ((BACKED_UP_COUNT += 1))
}

apply_file() {
  local relative_path="$1"
  local repo_path="${REPO_HOME_DIR}/${relative_path}"
  local system_path="${SYSTEM_HOME_DIR}/${relative_path}"

  if [[ ! -f "$repo_path" ]]; then
    log_warn "Skip (missing in repo): ${relative_path}"
    ((SKIPPED_COUNT += 1))
    return 0
  fi

  if [[ -e "$system_path" && -d "$system_path" ]]; then
    fatal "Destination is a directory (expected file): ${system_path}"
  fi

  mkdir -p "$(dirname "$system_path")"
  cp -a "$repo_path" "$system_path"
  log_info "Copied file: ${relative_path}"
  ((COPIED_FILE_COUNT += 1))
}

apply_dir() {
  local relative_path="$1"
  local repo_path="${REPO_HOME_DIR}/${relative_path}"
  local system_path="${SYSTEM_HOME_DIR}/${relative_path}"

  if [[ ! -d "$repo_path" ]]; then
    log_warn "Skip (missing in repo): ${relative_path}"
    ((SKIPPED_COUNT += 1))
    return 0
  fi

  if [[ -e "$system_path" && ! -d "$system_path" ]]; then
    fatal "Destination is not a directory: ${system_path}"
  fi

  mkdir -p "$system_path"
  rsync -a --delete "${repo_path}/" "${system_path}/"
  log_info "Synced dir: ${relative_path}"
  ((SYNCED_DIR_COUNT += 1))
}

print_summary() {
  log_info "Backup directory: ${BACKUP_DIR}"
  log_info "Backups: ${BACKED_UP_COUNT}, files: ${COPIED_FILE_COUNT}, dirs: ${SYNCED_DIR_COUNT}, skips: ${SKIPPED_COUNT}"
}

main() {
  local relative_path

  (($# == 0)) || fatal "This script does not accept arguments"
  require_commands rsync cp mkdir date
  validate_tracked_paths

  [[ -d "$REPO_HOME_DIR" ]] || fatal "Missing repo home directory: ${REPO_HOME_DIR}"

  BACKUP_DIR="${BACKUP_ROOT_DIR}/$(date +%Y%m%d-%H%M%S)"
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

  print_summary
}

main "$@"
