#!/bin/bash

set -euo pipefail

# shellcheck disable=SC2034
DOTFILES_CMD='collect'

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"
init_repo_paths "${BASH_SOURCE[0]}"

source "${REPO_ROOT_DIR}/bin/_tracked_paths.sh"

COPIED_FILE_COUNT=0
SYNCED_DIR_COUNT=0
SKIPPED_COUNT=0

copy_file() {
  local relative_path="$1"
  local system_path="${SYSTEM_HOME_DIR}/${relative_path}"
  local repo_path="${REPO_HOME_DIR}/${relative_path}"

  if [[ ! -f "${system_path}" ]]; then
    log_warn "Skip (missing in system): ${relative_path}"
    ((SKIPPED_COUNT += 1))
    return 0
  fi

  if [[ -e "${repo_path}" && -d "${repo_path}" ]]; then
    fatal "Destination is a directory (expected file): ${repo_path}"
  fi

  mkdir -p "$(dirname "${repo_path}")"
  cp -a "${system_path}" "${repo_path}"
  log_info "Copied file: ${relative_path}"
  ((COPIED_FILE_COUNT += 1))
}

copy_dir() {
  local relative_path="$1"
  local system_path="${SYSTEM_HOME_DIR}/${relative_path}"
  local repo_path="${REPO_HOME_DIR}/${relative_path}"

  if [[ ! -d "${system_path}" ]]; then
    log_warn "Skip (missing in system): ${relative_path}"
    ((SKIPPED_COUNT += 1))
    return 0
  fi

  if [[ -e "${repo_path}" && ! -d "${repo_path}" ]]; then
    fatal "Destination is not a directory: ${repo_path}"
  fi

  mkdir -p "${repo_path}"
  rsync -a --delete "${system_path}/" "${repo_path}/"
  log_info "Synced dir: ${relative_path}"
  ((SYNCED_DIR_COUNT += 1))
}

print_summary() {
  log_info "Files: ${COPIED_FILE_COUNT}, dirs: ${SYNCED_DIR_COUNT}, skips: ${SKIPPED_COUNT}"
  log_info "Repo directory: ${REPO_HOME_DIR}"
}

main() {
  local relative_path

  (($# == 0)) || fatal 'This script does not accept arguments'
  require_commands rsync cp mkdir
  validate_tracked_paths

  mkdir -p "${REPO_HOME_DIR}"

  for relative_path in "${TRACKED_DIRS[@]}"; do
    copy_dir "${relative_path}"
  done

  for relative_path in "${TRACKED_FILES[@]}"; do
    copy_file "${relative_path}"
  done

  print_summary
}

main "$@"
