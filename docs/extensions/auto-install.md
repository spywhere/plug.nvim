# Auto Install Extension

This extension will automatically install vim-plug and any missing plugins
during neovim start up

## Configurations

```lua
require('plug').extension.auto_install {
  -- automatically install vim-plug
  plug = true,
  -- automatically install missing plugins (this will also install plugins
  --   automatically on the first install)
  missing = true,
  -- delay in milliseconds before perform a post installation setup
  --   during installation for missing plugins
  post_install_delay = 100
}
```

## Event Handling

The extension will use the following events for its functionality

### `setup`

Check and attempt to install vim-plug automatically. If vim-plug cannot be
found or installed, the extension will signal plug.nvim to stop processing
all plugin setup.

### `plugin_options`

Mutate the plugin `do` option to perform a post installation during an
installation for missing plugins.

The original `do` option will still be performed afterward.

**Note** that `do` option that takes a command line will not be supported
when this extension mutated it.

### `done`

Attempt to install missing plugins and dispatch installation-related events.

## Event Dispatch

The extension will dispatch the following events during the process.

### `auto_install.first_install`

Produced when vim-plug has been installed for the first time. Run once all
plugin setup is done.

**Parameters:** _none_

### `auto_install.has_installed`

Produced when vim-plug has already installed. Run once all plugin setup is
done.

**Parameters:** _none_
