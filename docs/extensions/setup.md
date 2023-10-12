# Setup Extension

This extension will allow you to configure your plugin before it going to be
loaded using a closure

## Compatibility

- lazy.nvim: Proxy to `init`
- packer.nvim: Polyfilled with a custom handler for a compiled snapshot
- pckr.nvim: Proxy to `config_pre`
- vim-plug: Polyfilled

## Configurations

```lua
require('plug').extension.setup {}
```

## Usage

```lua
require('plug').setup {}

{
  'user/repo',
  -- a closure to be perform before a plugin is going to be loaded
  setup = function ()
    -- ...
  end
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `pre_setup`

Check and perform a plugin setup closure
