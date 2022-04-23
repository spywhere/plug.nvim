# Extension Authoring

This document will guide you through various section of how extension works

## Basic Extension Structure

An extension is simply a function that takes options from the user, then
perform a hook on various life cycle of the plugin and its manager

```lua
local my_extension = function (options)
  -- be sure to guard the options variable, as an extension could be called
  --   without any options
  local opts = options or {}
  -- we will explain what to expected in the next section

  -- here is your 'empty' extension so far
  return function ()
  end
end

-- later in the plugin configurations
require('plug').setup {
  extensions = {
    my_extension {
      -- your extension options go here
    }
  }
}
''
```

## Extension Type and Ability

An extension can be setup in 2 different ways depends on how your extension
going to behave

### Extension that handle events

If your extension only handle on specific events, your extension function
could simply return a function that takes a 'hook' function

```lua
local my_extension = function (options)
  return function (hook)
    -- your plugin code and hook setup goes here
  end
end
```

Be sure to take a look into [Hook Setup](#hook-setup) section below for
more details

### Extension that dispatch events

If your extension expected to not only handle on specific events but also to
dispatch a new event, your extension function should return a table with 2
keys, 'name' and 'entry' respectively

```lua
local my_extension = function (options)
  return {
    -- your extension name (snake_case is preferred here)
    name = 'my_extension',
    -- your extension entry point, takes 'hook' and 'dispatch' function
    entry = function (hook, dispatch)
      -- your plugin code, hook setup and event dispatch goes here
    end
  }
end
```

Be sure to take a look into [Hook Setup](#hook-setup) and
[Event Dispatch](#event-dispatch) section below for more details

## Events

During the setup process, plug.nvim will dispatch its own events to the
handlers (setup using a hook). Here are a list of events it produced on
its own

### `plugin`

Produced for each of the plugin user is setting up (either through `setup`
call, `plug.install` or `use` function)

**Parameters**:

- `plugin`: a plugin (see [Plugin](#plugin) type below)

**Returns**:

A new plugin setup, or `nil` to keep the current plugin setup

### `plugin_collected`

Produced when all plugins setup has been collected, typically immediately
after call `plug.ended` function

**Parameters**:

- `plugins`: a list of plugins (see [Plugin](#plugin) type below)

**Returns**:

A new list of plugins, or `nil` to keep the current list

### `pre_setup`

Produced right after `plugin_collected` event

**Parameters**:

- `plugins`: a list of plugin (see [Plugin](#plugin) type below)

**Returns**: _none_

### `setup`

Produced right after `pre_setup` event

**Parameters**:

- `plugins`: a list of plugin (see [Plugin](#plugin) type below)

**Returns**:

Any value will be discarded, or returns `false` to prevent plug.nvim to
process with the installation of all plugins

### `plugin_options`

Produced when plug.nvim try to setup a plugin through vim-plug

**Parameters**:

- `options`: a plugin option (see [Options](#options) type below)
- `perform_post`: a function that upon called will perform a post
installation setup

**Returns**:

A new plugin options, or `nil` to keep the current plugin options

### `plugin_post`

Produced when a plugin has been loaded or lazy loaded

**Parameters**:

- `plugin`: a plugin (see [Plugin](#plugin) type below)
- `is_lazy`: a boolean indicated if a plugin has been lazy loaded
- `perform_post`: a function that upon called will perform a post
installation setup

**Returns**: _none_

### `done`

Produced when plug.nvim has setup all plugins

**Parameters**: _none_

## Types

### Plugin

A table containing a plugin setup

```lua
{
  -- a name of plugin passed from the `setup`, `plug.install` or `use` function
  name = '',
  -- a map of plugin options that will be passed to vim-plug
  options = nil,
  -- any other key that the user might set during setup
}
```

### Options

A table containing a plugin options, see
[`Plug` options](https://github.com/junegunn/vim-plug#plug-options)

## Hook Setup

Upon setup your extension, you should already have access to a `hook`
function.

This function will takes 2 parameters as follows

- `event`: An event name to be handled by the extension
- `handler`: An event handler, which takes 'event context' (see
[Event Context](#event-context) below)as a first argument and the rest are
event parameters

## Event Context

Event context is simply a shared object to be used by the extension. This
context object will be persist across life cycle of the plugin, so it is
a best place to store any state you might need for later use

## Event Dispatch

With `dispatch` function available, your extension can notify another
extension for certain events that might occurred by your extension.

Please note that event dispatched from your extension will always prefixed
with an extension name. So if your plugin named `my_extension` and dispatch
`my_event` event, the handler on another extension should handle the event
named `my_extension.my_event`.
