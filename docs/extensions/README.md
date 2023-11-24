# Extensions

plug.nvim comes bundled with some set of extensions

- [`auto_install`](/docs/extensions/auto-install.md): Automatic plugin manager
installation and auto installation for missing plugins
- [`config`](/docs/extensions/config.md): Add a support for per-plugin configuration closure
- [`defer`](/docs/extensions/defer.md): Add a support for per-plugin deferred configurations
- [`priority`](/docs/extensions/priority.md): Add a support for plugin loading priority and sequencing
- [`proxy`](/docs/extensions/proxy.md): Add a support for proxy plugin configurations to backend's plugin options
- [`requires`](/docs/extensions/requires.md): Add a support for plugin requirements
- [`setup`](/docs/extensions/setup.md): Add a support for plugin pre-loading setup
- [`skip`](/docs/extensions/skip.md): Add a support for conditionally plugin skipping

Note that some extensions will dictate how plug.nvim will process the setup.
You can refer to each extension configurations and setup by following a link
of the extension.

# Extension Compatibility

Each built-in extensions will have its compatibility matrix to indicate the
compatibility with each backends. The following are the explanation of each
compatibility meaning

- Proxy to `name`: The extension will simply used the value as-is. Similar to
how the plugin will be configured natively
- Polyfilled: The extension will make a workaround in order to support such
feature for the plugin manager
- Untested: The feature might work for certain backends, required some testing

## Extension Authoring

If you wish to implement your own extension, feel free to check out
[how to build your own extension](/docs/extensions/api.md). This should give
you an overview of how extension works as well as what is available to you.
