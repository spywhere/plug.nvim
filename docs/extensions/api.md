# Extension Authoring

This document will guide you through various section of how extension works

Be sure to check out [built-in extensions](../../extensions) for some example
usages

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

An extension can be setup in 2 different ways depends on how your extension is
going to behave

### Extension that handle events

If your extension only handle on specific events, your extension function
could simply return a function that takes a 'hook' function and a backend
'context'

```lua
local my_extension = function (options)
  return function (hook, context)
    -- your extension code and hook setup goes here
  end
end
```

Be sure to take a look into [Hook Setup](#hook-setup) and
[Backend Context](#backend-context) section below for more details

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
    --   as well as a backend 'context'
    entry = function (hook, dispatch, context)
      -- your extension code, hook setup and event dispatch goes here
    end
  }
end
```

If there are more than one extension being setup that have the same name,
only the first extension will get loaded.

Be sure to take a look into [Hook Setup](#hook-setup),
[Backend Context](#backend-context) and [Event Dispatch](#event-dispatch)
section below for more details

## Events

During the setup process, plug.nvim will dispatch its own events to the
handlers (setup using a hook). Here are a list of events it produced on
its own.

**Note** that returns `false` value in any event will stop the next
extension from handling the event.

### `plugin`

Produced for each of the plugin user is setting up (either through `setup`
call, `plug.install` or `use` function)

**Parameters**:

- `plugin`: a plugin definition (see [Plugin Definition](#plugin-definition)
type below)
- `install_plugin`: a function that upon called will setup another plugin.
This function takes 2 parameters...
  - `mutator` (optional): a function that will mutate a plugin definition
before setup. This function takes 2 parameters...
    - `plugin`: a plugin definition (see
[Plugin Definition](#plugin-definition) type below)
    - `containment`: a table containing...
      - `plugin`: a plugin definition (see
[Plugin Definition](#plugin-definition) type below)
      - `hold`: a boolean value indicated if a containment plugin has been
processed by an extension earlier
  - `plugin`: a plugin definition (see [Plugin Definition](#plugin-definition)
type below)

**Returns**:

New plugin definitions, returns `nil` to keep the current plugin definitions
or returns `false` to prevent the plugin from loading

### `plugin_collected`

Produced when all plugin definitions has been collected, typically immediately
after call `plug.ended` function

**Parameters**:

- `plugins`: a list of plugin definitions (see
[Plugin Definition](#plugin-definition) type below)

**Returns**:

A new list of plugins, or returns `nil` to keep the current list

### `pre_setup`

Produced right after `plugin_collected` event

**Parameters**:

- `plugins`: a list of plugin definitions (see
[Plugin Definition](#plugin-definition) type below)

**Returns**: _none_

### `setup`

Produced right after `pre_setup` event

**Parameters**:

- `plugins`: a list of plugin definitions (see
[Plugin Definition](#plugin-definition) type below)

**Returns**:

Any value will be discarded, or returns `false` to prevent plug.nvim to
proceed with the installation of all plugins

### `plugin_options`

Produced when plug.nvim try to setup a plugin through plugin manager

**Parameters**:

- `options`: plugin options (see [Options](#options) type below)
- `perform_post`: a function that upon called will perform a post
installation setup
- `plugin`: a plugin definition (see [Plugin Definition](#plugin-definition)
type below)

**Returns**:

New plugin options, or returns `nil` to keep the current plugin options

### `post_setup`

Produced when plug.nvim has setup all plugins

**Parameters**:

- `plugins`: a list of plugin definitions (see
[Plugin Definition](#plugin-definition) type below)

**Returns**:

Any value will be discarded, or returns `false` to prevent plug.nvim to
proceed with plugin configurations (note that plugins are still loaded but
not get configured in this step)

### `plugin_post`

Produced when a plugin has been loaded or lazy loaded

**Parameters**:

- `plugin`: a plugin definition (see [Plugin Definition](#plugin-definition)
type below)
- `is_lazy`: a boolean indicated if a plugin has been lazy loaded
- `perform_post`: a function that upon called will perform a post
installation setup

**Returns**: _none_

### `done`

Produced when plug.nvim has complete its plugin setups and configurations

**Parameters**: _none_

## Types

### Plugin Definition

A table containing a plugin definition

```lua
{
  -- a name of plugin passed from the `setup`, `plug.install` or `use` function
  name = '',
  -- a boolean value to indicated if this plugin will be lazy loaded
  lazy = false,
  -- a table of plugin options that will be passed to plugin manager
  options = nil,
  -- any other key that the user might set during setup
}
```

### Options

A table containing a plugin options to be passed to plugin manager, see

- [vim-plug `Plug` options](https://github.com/junegunn/vim-plug#plug-options)
- [packer.nvim `use` options](https://github.com/wbthomason/packer.nvim#specifying-plugins)

## Hook Setup

Upon setup your extension, you should already have access to a `hook`
function.

This function will takes 2 parameters as follows

- `event`: An event name to be handled by the extension
- `handler`: An event handler, which takes 'event context' (see
[Event Context](#event-context) below) as a first argument and the rest are
event parameters

```lua
local my_extension = function (options)
  local my_event_handler = function (event_context, ...)
    local event_parameters = { ... }

    -- your event handling code here
  end

  return function (hook, backend_context)
    hook('event_name', my_event_handler)
  end
end
```

Please see a note on event handling with multiple extensions in
[Events](#events) section above

## Backend Context

Backend context is simply an object set by the backend itself. All backend
will have `backend` key to indicate which backend currently being used

## Event Context

Event context is simply a shared object to be used by the extension. This
context object will be persist across life cycle of the extension, so it is
a best place to store any state you might need for later use

## Event Dispatch

With `dispatch` function available, your extension can notify another
extension for certain events that might occurred by your extension.

This function will takes an event name and event parameters as follows

- `event`: An event name to be handled by the extension
- _rest of arguments_: Event parameters

```lua
local my_extension = function (options)
  return {
    name = 'my_extension',
    entry = function (hook, dispatch, context)
      -- this call will dispatch an event name 'my_extension.my_event' with
      --   2 event parameters
      dispatch('my_event', 'additional', 'payload')
    end
  }
end
```

Please note that event dispatched from your extension will always prefixed
with an extension name. So if your extension named `my_extension` and dispatch
`my_event` event, the handler on another extension should handle the event
named `my_extension.my_event`.
