# Skip Extension

This extension will allow you to skip a plugin loading according to the
condition specified

**Note** that this extension should go first in order to prevent other
extensions to load a plugin

## Configurations

```lua
require('plug').extension.skip {}
```

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

The extension will use the following events for its functionality

### `plugin`

Check if the plugin is being skipped, if so prevent the plugin from loading
