# Needs Extension

This extension will allow you to ensure a certain set of variables is set
before a plugin is configured

This extension will simply be useless if used alone. Be sure to have some
extensions that handled on `plugin_post` event to have this plugin control
its behaviour

**Note** that this extension should go first in order to prevent other
extensions to load a plugin

## Compatibility

- lazy.nvim: Polyfilled, Untested
- packer.nvim: Polyfilled, Untested
- pckr.nvim: Polyfilled, Untested
- vim-plug: Polyfilled

## Configurations

```lua
require('plug').extension.needs {
  -- a delay in milliseconds before schedule a next checking run if variables
  --   are not fulfilled
  delay_post = nil -- default to `delay_post` of plug.nvim
}
```

## Usage

```lua
require('plug').setup {}

{
  'user/repo',
  -- a table containing variables and its value to be check against
  needs = {
    -- support the following variable scopes
    --   g   = global
    --   b   = buffer
    --   w   = window
    --   t   = tabpage
    --   v   = v: variables
    --   env = environment variables
    g = {
      ['var'] = 'value'
    }
  }
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_post`

Check the given variables and schedule a delayed check if variables are
not matched.
