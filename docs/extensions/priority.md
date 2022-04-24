# Priority Extension

This extension will allow you to configure a plugin loading priority

## Configurations

```lua
require('plug').extension.priority {}
```

## Usage

```lua
require('plug').setup {}

{
  'repo/user',
  -- a loading priority of the plugin
  priority = 0
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_collected`

Perform a plugin prioritization to make sure it being loaded in order
