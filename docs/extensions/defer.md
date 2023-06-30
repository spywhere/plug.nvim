# Defer Extension

This extension will allow you to configure your plugin using a closure

## Compatibility

- vim-plug: Polyfilled
- packer.nvim: Polyfilled
- lazy.nvim: Not yet supported

## Configurations

```lua
require('plug').extension.defer {
  -- a delay in milliseconds before perform a `delay` closure
  defer_delay = nil -- default to `delay_post` of plug.nvim
}
```

## Usage

```lua
require('plug').setup {}

{
  'user/repo',
  -- a closure to be perform last once a plugin is loaded
  defer = function ()
    -- ...
  end,
  -- a closure to be perform after a specific delay once a plugin is loaded
  delay = function ()
    -- ...
  end
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_post`

Check and perform a deferred / delayed closure
