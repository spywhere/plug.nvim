# Breaking Changes

Check out [change log](/CHANGELOG.md) for extensive list of changes.

## Important Notice

Until v1.0.0 is release, please do expected a breaking change to happen
occationally. When such change is to be expected, a deprecation notice will
be release one MINOR version before.

## 2023-11-25

- (removed) `needs`: Extension is no longer available.
- (removed) Upgrade command injections are no longer available.
- (removed) `backend`: backend is no longer accepts string.

## 2023-10-11

- (deprecated) `needs`: Due to its niche usages and how easy it could be
implemented, `needs` extension will be removed in the future release.
- (deprecated) Due to a different variation of an upgrade command for each
backend, upgrade command injection will be removed in the future release.

## 2023-09-29

- (deprecated) `backend`: backend is no longer accepts string. Suggests to use
one of the backend available through `require('plug').backend` instead.

## 2023-07-01

- (requirement) `backend`: backend is no longer an optional nor
opinionated by default.
- (removed) `plugin_dir`: backend specific configurations are now named
as `options`.

## 2023-01-23

- (deprecated) `plugin_dir`: backend specific configurations are now named
as `options`. For `vim-plug` backend, simply rename `plugin_dir` to
`options` should set a plugin directory correctly.

## Prior updates

- Latest version before supporting multiple backend, check out
[vim-plug](https://github.com/spywhere/plug.nvim/tree/vim-plug)
- Latest version supporting neovim v0.5.1, check out
[nvim-0.5.1](https://github.com/spywhere/plug.nvim/tree/nvim-0.5.1)
