# plug.nvim

[![GitHub Tag](https://img.shields.io/github/v/tag/spywhere/plug.nvim?logo=github)](/CHANGELOG.md)

An extensible layer for plugin management in pure lua.

Thus this plugin is not a plugin manager, so a plugin manager backend will
either need to be installed manually or configured to be automatically
installed.

## Shortcuts

* [Getting Started](/docs/getting-started.md)
* [Breaking Changes](/docs/breaking-changes.md) / [Change Log](/CHANGELOG.md)
* [Configurations and Upgrade](/docs/configurations.md)
* [Backends](/docs/backends)
* [Extensions](/docs/extensions)

## Features

This plugin will behave with the exact same set of its backend plugin manager.
Only with the ability to extends its behaviour.

So with some built-in configurations, you could achieve...

- Plugin manager automatic installation
- Automatic installation of missing plugins
- Per-plugin configuration closure
- Plugin and variable requirements
- Plugin loading priority and sequencing
- Defers setup
- Conditionally install a plugin
- [And more...](/docs/extensions)

<details>

<summary>

## Contributes

</summary>

During the development, you can use the following command to automatically
setup a working configurations to test the plugin...

```sh
make test-<backend to test>

# or to preview the test setup

make drytest-<backend to test>
```

To test automatic installation, use

```sh
make test-auto-<backend to test>

# or to preview the test setup

make drytest-auto-<backend to test>
```

To preview the code generation, use

```sh
make preview
```

To manually generate the output code, use

```sh
make compile
```

</details>

## License

Released under the [MIT License](LICENSE)
