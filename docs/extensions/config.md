# Config Extension

This extension will allow you to configure your plugin using a closure

## Compatibility

- lazy.nvim: Proxy to `config`
- packer.nvim: Proxy to `config`. With a custom handler for a compiled snapshot
- pckr.nvim: Proxy to `config`
- vim-plug: Polyfilled

## Configurations

```lua
require('plug').extension.config {}
```

## Usage

```lua
require('plug').setup {}

{
  'user/repo',
  -- a configuration closure to be perform once a plugin is loaded
  config = function ()
    -- plugin configurations go here
  end
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_post`

Check and perform a plugin configuration closure
