#!/usr/bin/env bash

set -euo pipefail

DOTFILES_CMD="status"

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

differences=()

check_path() {
  local relative_path="$1"
  local repo_path="$REPO_HOME_DIR/$relative_path"
  local system_path="$SYSTEM_HOME_DIR/$relative_path"

  # If neither side exists, ignore (e.g., path removed from both places).
  if [[ ! -e "$repo_path" && ! -e "$system_path" ]]; then
    return 0
  fi

  if [[ ! -e "$repo_path" && -e "$system_path" ]]; then
    differences+=("$relative_path (only in system)")
    return 0
  fi

  if [[ -e "$repo_path" && ! -e "$system_path" ]]; then
    differences+=("$relative_path (missing in system)")
    return 0
  fi

  # Both exist. If type differs, mark modified.
  if [[ -d "$repo_path" && ! -d "$system_path" ]]; then
    differences+=("$relative_path (type mismatch)")
    return 0
  fi

  if [[ ! -d "$repo_path" && -d "$system_path" ]]; then
    differences+=("$relative_path (type mismatch)")
    return 0
  fi

  if [[ -d "$repo_path" ]]; then
    if ! diff -qr "$repo_path" "$system_path" >/dev/null 2>&1; then
      differences+=("$relative_path (modified)")
    fi
    return 0
  fi

  if ! diff -q "$repo_path" "$system_path" >/dev/null 2>&1; then
    differences+=("$relative_path (modified)")
  fi
}

main() {
  require_command diff

  [[ -d "$REPO_HOME_DIR" ]] || fatal "Missing repo home directory: $REPO_HOME_DIR"

  for dir in "${TRACKED_DIRS[@]}"; do
    check_path "$dir"
  done

  for file in "${TRACKED_FILES[@]}"; do
    check_path "$file"
  done

  if [[ "${#differences[@]}" -eq 0 ]]; then
    log_info "Clean (repo matches system)"
    exit 0
  fi

  log_info "Differences found:"

  for item in "${differences[@]}"; do
    printf ' - %s\n' "$item"
  done

  exit 1
}

main "$@"
