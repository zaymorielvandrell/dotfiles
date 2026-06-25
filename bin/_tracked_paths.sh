#!/bin/bash

TRACKED_DIRS=(
  ".bin"
  ".config/nvim"
)

TRACKED_FILES=(
  ".bash_profile"
  ".bashrc"
  ".config/ghostty/config"
  ".config/starship.toml"
  ".gitconfig"
  ".tmux.conf"
)

validate_tracked_paths() {
  local -A seen_paths=()
  local dir_path
  local file_path
  local other_dir_path

  for dir_path in "${TRACKED_DIRS[@]}"; do
    if [[ -n "${seen_paths[${dir_path}]:-}" ]]; then
      fatal "Duplicate tracked path: ${dir_path}"
    fi
    seen_paths["${dir_path}"]="dir"

    for other_dir_path in "${TRACKED_DIRS[@]}"; do
      if [[ "$dir_path" == "$other_dir_path" ]]; then
        continue
      fi

      if [[ "$dir_path" == "$other_dir_path"/* ]]; then
        fatal "Nested tracked directories are not allowed: ${dir_path}"
      fi
    done

    for file_path in "${TRACKED_FILES[@]}"; do
      if [[ "$dir_path" == "$file_path" ]]; then
        fatal "Path tracked as both file and directory: ${dir_path}"
      fi

      if [[ "$file_path" == "$dir_path"/* ]]; then
        fatal "Tracked file overlaps tracked directory: ${file_path}"
      fi
    done
  done

  for file_path in "${TRACKED_FILES[@]}"; do
    if [[ -n "${seen_paths[${file_path}]:-}" ]]; then
      fatal "Duplicate tracked path: ${file_path}"
    fi
    seen_paths["${file_path}"]="file"
  done
}
