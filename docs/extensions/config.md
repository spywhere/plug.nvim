# Config Extension

This extension will allow you to configure your plugin using a closure

## Configurations

```lua
require('plug').extension.config {}
```

## Usage

```lua
require('plug').setup {}

{
  'repo/user',
  -- a configuration closure to be perform once a plugin is loaded
  config = function ()
    -- plugin configurations go here
  end
}
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_post`

Check and perform a plugin configuration closure
