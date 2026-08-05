# Fcitx5 backup

This directory mirrors the portable configuration from `~/.config/fcitx5`.
The `profile` file was copied through its Home Manager symlink as a regular
file so the backup does not depend on a `/nix/store` path.

The active profile contains `keyboard-us` and `rime`. `pinyin.conf` is kept
because it exists in the current Fcitx5 configuration, but Pinyin is not
enabled by the active profile.

The generated `cached_layouts` file is intentionally omitted.
