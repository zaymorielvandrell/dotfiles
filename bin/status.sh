#!/bin/bash

set -euo pipefail

# shellcheck disable=SC2034
DOTFILES_CMD='status'

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"
init_repo_paths "${BASH_SOURCE[0]}"

source "${REPO_ROOT_DIR}/bin/_tracked_paths.sh"

differences=()

check_path() {
  local relative_path="$1"
  local repo_path="${REPO_HOME_DIR}/${relative_path}"
  local system_path="${SYSTEM_HOME_DIR}/${relative_path}"

  if [[ ! -e "${repo_path}" && ! -e "${system_path}" ]]; then
    return 0
  fi

  if [[ ! -e "${repo_path}" && -e "${system_path}" ]]; then
    differences+=("${relative_path} (only in system)")
    return 0
  fi

  if [[ -e "${repo_path}" && ! -e "${system_path}" ]]; then
    differences+=("${relative_path} (missing in system)")
    return 0
  fi

  if [[ -d "${repo_path}" && ! -d "${system_path}" ]]; then
    differences+=("${relative_path} (type mismatch)")
    return 0
  fi

  if [[ ! -d "${repo_path}" && -d "${system_path}" ]]; then
    differences+=("${relative_path} (type mismatch)")
    return 0
  fi

  if [[ -d "${repo_path}" ]]; then
    if ! diff -qr "${repo_path}" "${system_path}" >/dev/null 2>&1; then
      differences+=("${relative_path} (modified)")
    fi
    return 0
  fi

  if ! diff -q "${repo_path}" "${system_path}" >/dev/null 2>&1; then
    differences+=("${relative_path} (modified)")
  fi
}

print_summary() {
  if ((${#differences[@]} == 0)); then
    log_info 'Clean (repo matches system)'
    return 0
  fi

  log_info "Differences found: ${#differences[@]}"
  printf ' - %s\n' "${differences[@]}"
}

main() {
  local relative_path

  (($# == 0)) || fatal 'This script does not accept arguments'
  require_commands diff
  validate_tracked_paths

  [[ -d "${REPO_HOME_DIR}" ]] || fatal "Missing repo home directory: ${REPO_HOME_DIR}"

  for relative_path in "${TRACKED_DIRS[@]}"; do
    check_path "${relative_path}"
  done

  for relative_path in "${TRACKED_FILES[@]}"; do
    check_path "${relative_path}"
  done

  print_summary

  if ((${#differences[@]} > 0)); then
    exit 1
  fi
}

main "$@"
