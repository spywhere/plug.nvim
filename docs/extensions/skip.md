# Skip Extension

This extension will allow you to skip a plugin loading according to the
condition specified.

**Note** that this extension should go first in order to prevent other
extensions to load a plugin.

## Compatibility

- lazy.nvim: Proxy to `enabled`
- packer.nvim: Proxy to `disable`
- pckr.nvim: Polyfilled as `remove`
- vim-plug: Polyfilled as `remove`

## Configurations

```lua
require('plug').extension.skip {
  -- skipping behavior
  --   set to 'disable' to disable a plugin when possible
  --   set to 'remove' to skip a plugin installation/loading
  behavior = 'disable'
}
```

**Note** When plugins are disabled instead of removed, some callback extensions
(such as 'setup' or 'defer') might still active for those plugins. If you wish
to also disable those callbacks, setting the behavior to `remove` might give
a desired effect.

## Usage

```lua
require('plug').setup {}

{
  'user/repo',
  -- a boolean value to indicate whether a plugin will be skipped or not
  skip = false,
  -- or it could be a function that returns a boolean value
  skip = function () return false end
}

''
```

## Event Handling

The extension will use the following events for its functionality.

### `plugin`

Check if the plugin is being skipped, if so prevent the plugin from loading.

### `plugin_options`

Perform proxy for plugin disable options.
