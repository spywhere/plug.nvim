# Config Extension

This extension will allow you to configure your plugin using a closure

## Compatibility

- vim-plug: Polyfilled
- packer.nvim: Proxy to `config`

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
