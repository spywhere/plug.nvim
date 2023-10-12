# Skip Extension

This extension will allow you to proxy a specific key in plugin configurations
as one of the `options`, plugin manager options for the plugin

**Note** that this extension does not verify the options supported by the
backend. It simply proxy plugin configurations to `options`

## Compatibility

This plugin does not depends on any specific backend, so it works with any
backend

## Configurations

```lua
-- pass it as a simple option key map
require('plug').extension.proxy {
  -- option map goes here, see example mapping below

  -- proxy 'key' to 'options'
  'key',

  -- proxy 'from' as 'to' to 'options'
  from = 'to'
}

-- or pass it as a function that accepts backend name and returns an option
--   key map
require('plug').extension.proxy(function (backend)
  return {
    -- option map goes here, see example mapping below

    -- proxy 'key' to 'options'
    'key',

    -- proxy 'from' as 'to' to 'options'
    from = 'to'
  }
end)
```

## Usage

```lua
require('plug').setup {}

-- with key map set to
--   {
--     'key',
--     from = 'to'
--   }
-- these plugin configurations
{
  'user/repo',
  key = 'value', -- note that value can be any type
  from = function () end
}
-- has the same meaning as
{
  'user/repo',
  options = {
    key = 'value',
    to = function () end
  }
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_options`

Perform proxy for option keys
