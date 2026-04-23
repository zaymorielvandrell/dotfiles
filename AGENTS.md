# AGENTS.md

## Repo Model

- This repo is a copy-based dotfiles snapshot, not a symlink manager. `home/` mirrors the subset of `$HOME` that is tracked and deployed.
- The authoritative tracked-path list lives in `bin/_tracked_paths.sh`. If a dotfile is not listed there, `bin/collect.sh`, `bin/apply.sh`, and `bin/status.sh` will ignore it.

## Core Commands

- `bin/status.sh`: compares `home/` against live `$HOME` for every tracked path and exits non-zero when any difference is found.
- `bin/collect.sh`: copies tracked content from live `$HOME` into `home/`. Tracked directories use `rsync -a --delete`; tracked files use `cp -a`.
- `bin/apply.sh`: copies tracked content from `home/` into live `$HOME`. It creates a timestamped backup under `.backup/` first, then syncs tracked directories with `rsync -a --delete`.
- The `bin/` scripts are intentionally minimal and do not accept CLI arguments; they always process the full tracked set.
- `rsync` is required for `bin/collect.sh` and `bin/apply.sh`; `diff` is required for `bin/status.sh`.

## Safety-Critical Behavior

- Treat `bin/apply.sh` as destructive for tracked directories: because it uses `rsync -a --delete`, files present in `$HOME/.bin` or `$HOME/.config/nvim` but missing from `home/` will be removed from the live home directory.
- `.backup/` is intentionally gitignored and stores `bin/apply.sh` backups only.

## Tracked Scope

- Tracked directories: `.bin`, `.config/nvim`.
- Tracked files: `.bash_profile`, `.bashrc`, `.config/ghostty/config`, `.config/starship.toml`, `.gitconfig`, `.tmux.conf`.
- `home/.bin/` contains user-invoked executables without `.sh` extensions; keep them extensionless and self-contained rather than sourcing shared helpers from `bin/`.

## Neovim Structure

- Neovim is the only code-heavy subtree. Entry flow is `home/.config/nvim/init.lua` -> `lua/config/lazy.lua`.
- `lua/config/lazy.lua` bootstraps `lazy.nvim` and loads `LazyVim/LazyVim` plus local plugin specs from `lua/plugins/*.lua`.
- Put general editor settings in `lua/config/options.lua`; put plugin overrides in separate files under `lua/plugins/`.
- `home/.config/nvim/lazyvim.json` enables LazyVim extras; check it before adding language/tooling plugins that may already be provided there.
- `home/.config/nvim/lazy-lock.json` pins plugin commits. Only update it when intentionally changing plugin versions.

## Formatting And Verification

- Root `.editorconfig` sets 2-space indentation, LF endings, and final newlines for the repo.
- Neovim Lua uses `home/.config/nvim/stylua.toml` (`indent_width = 2`, `column_width = 100`). Run `stylua home/.config/nvim` after editing Lua if `stylua` is available.
- There is no repo-wide test or CI config in this snapshot. For shell script edits, use focused checks like `bash -n bin/*.sh` or `bash -n home/.bin/*`.
- For shell linting, use `shellcheck -x -P bin bin/*.sh` for the `bin/` scripts; `home/.bin/*` can be linted directly with `shellcheck`.
- For sync behavior, use `bin/status.sh` before and after changes instead of guessing.
