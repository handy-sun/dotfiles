# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository scope

This repo is a personal dotfiles repository. It is not an application with a build, test, or lint pipeline. Work here is usually editing individual tool configs under `.config/` plus Vim config under `dotvim/`.

## Common commands

| Task | Command |
| --- | --- |
| Show repo status | `git status --short` |
| Review changes | `git diff` |
| Reload tmux config in a running session | `tmux source-file ~/.config/tmux/tmux.conf` |
| Check tmux config parses | `tmux -f ~/.config/tmux/tmux.conf start-server \; show-options -g > /dev/null` |
| Check Alacritty config parses | `alacritty --config-file ~/.config/alacritty/alacritty.toml -e true` |
| Inspect Yazi package/plugins config | `yazi --debug` |
| Sync Yazi plugins declared in package.toml | `ya pkg install` |
| Start PHP-FPM with this local config | `php-fpm --fpm-config ~/.config/php/php-fpm.conf --nodaemonize` |
| Validate fontconfig XML | `xmllint --noout ~/.config/fontconfig/fonts.conf` |
| Check clangd YAML config | `python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('~/.config/clangd/config.yaml').expanduser().read_text())"` |

## Architecture

### Layout

- `.config/` contains most active configuration, grouped by tool.
- `dotvim/` contains Vim/Neovim-related config that is still kept separately from `.config`.
- There is no central bootstrap script or Nix/Home Manager entrypoint in this repo right now; changes are generally applied by editing the target config file directly.

### Yazi is the most code-like area

Yazi has the richest internal structure in this repo and is the closest thing to a composed system:

- `.config/yazi/yazi.toml` defines manager behavior, open rules, and plugin/previewer wiring.
- `.config/yazi/keymap.toml` adds custom keybindings, especially plugin entrypoints.
- `.config/yazi/init.lua` configures runtime plugin behavior and statusline/theme composition.
- `.config/yazi/package.toml` pins external plugin and flavor dependencies.
- `.config/yazi/plugins/*` and `.config/yazi/flavors/*` vendor plugin/theme code that `init.lua` and `keymap.toml` rely on.

Important relationships:

- `yazi.toml` registers plugin hooks such as `git` fetchers and `preview-git` / `ouch` previewers.
- `init.lua` calls `require('git'):setup(...)` and `require('yatline'):setup(...)`, so changes to plugin names or dependency pins must stay consistent with `package.toml` and vendored plugin directories.
- `keymap.toml` is tightly coupled to installed plugins such as `fast-enter`, `ouch`, and `sudo`.

### Terminal/editor stack assumptions

Several configs assume a terminal-first workflow with consistent keyboard behavior across tools:

- `.config/alacritty/alacritty.toml` defines terminal appearance plus extensive custom key translations.
- `.config/tmux/tmux.conf` uses a Vim-like navigation model, remaps the tmux prefix to `Ctrl-s`, and enables mouse support.
- `dotvim/coc-settings.json` configures language servers and completion behavior for C/C++, CMake, and Vim script.
- `.config/clangd/config.yaml` provides fallback compile flags for C++ tooling.

When changing keybindings or escape sequences, check both Alacritty and tmux so they stay compatible.

### Other configs are mostly standalone

Most remaining directories under `.config/` are single-tool configs with minimal cross-file coupling:

- `fontconfig` customizes synthetic slant/bold behavior and font discovery.
- `php/php-fpm.conf` is a small local PHP-FPM socket/pool config.
- `ranger`, `joshuto`, `mpv`, `pip`, `ghostty`, `bat`, `eza`, and `git` are conventional per-tool config areas.

## Working guidance for this repo

- Prefer minimal, tool-specific edits over introducing new structure.
- Verify changes with the tool that owns the config whenever possible instead of inventing generic validation steps.
- For Yazi work, check `yazi.toml`, `keymap.toml`, `init.lua`, and `package.toml` together before changing plugin-related behavior.
- For terminal input issues, trace behavior across Alacritty, tmux, and Vim configs rather than treating any one file in isolation.
