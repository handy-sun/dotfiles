# Fcitx5 / Rime backup

This directory mirrors the portable part of `~/.local/share/fcitx5/rime` on
the current machine.

- `default.custom.yaml` and `rime_ice.custom.yaml` are the active Rime and
  雾凇输入方案 overrides.
- `rime_ice.userdb.txt` is the portable user-dictionary/learning export from
  the active Rime sync directory.

The base 雾凇 schemas and dictionaries are supplied by the current Nix
`rime-ice-2026.06.30` package; this backup stores the local overrides rather
than duplicating that package.

The generated `build/` directories, binary `rime_ice.userdb` database,
`installation.yaml`, `user.yaml`, sync metadata, locks, and logs are omitted.
They contain generated or machine-specific state and should not be deployed
as configuration.
