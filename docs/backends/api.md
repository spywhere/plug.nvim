# Backend Authoring

This document will guide you through various section of how backend works.

## Basic Backend Structure

A backend is simply a function that takes in plugin manager's options from the
user, then providing implementation on various life cycle of the plugin setup
and its manager.

A backend **MUST** implement at least 2 things.

- A backend name
- An implementation for plugin setup


```lua
local my_backend = function (ctx)
  local M = {
    -- name of this backend
    name = 'my backend',

    -- backend specific context to passed to the extensions
    --   some extensions might required a backend to implement certain
    --   behaviors to fulfill the functionality required for the extension
    --   to work.
    context = {
      -- your context for extensions go here

      -- a command string or a function to be called in order to install
      --   required plugins.
      --
      --   - first_install: boolean = a flag indicate the first plugins
      --                                installation or a subsequence
      --                                installation for the missing one
      --
      -- required by 'auto-install' extension
      install_command = function (first_install)
      end,

      -- a function to be called to setup a hook for the extension
      --
      -- for example, if the plugin manager required a callback that must be
      --   managed by the extension
      --
      -- this is typically done by building a function call snippet in one of
      --   the following forms (as an example)
      --
      --   require('plug').extension.<ext>.<plugin name>(<kind>)
      --   require('plug').extension.<ext>.<function name>(<options>)
      --
      --   - ext: string        = an extension name
      --   - name: string       = an internal (table/function) name for call
      --                            snippet
      --   - kind: string | nil = a 'kind' of handler to be setup
      --
      -- required by 'config', 'setup' and 'defer' extension
      setup_handler = function (ext, name, kind)
      end
    },

    -- additionally, you can use this 'module' to store privately accessible
    --   data, such as internal state of the backend or its configurations
    --   (for example, a plugin installation path or plugin manager repository
    --   URL)
  }

  -- a function to check if the plugin manager is properly setup or not
  --
  -- returns a boolean
  M.is_installed = function ()
  end

  -- a function to install the plugin manager
  --
  -- returns a boolean indicate the installation result (`true` for a
  --   successful installation)
  M.install = function ()
  end

  -- a table describe a support for lazy-loading plugins
  M.lazy = {
    -- a key for setting a flag for lazy-loading plugins for this particular
    --   backend's plugin specification
    key = '',

    -- a function to mutate the plugin specification to accounted for
    --   lazy-loading before processed by the main 'setup'
    --
    --   - plugin: table   = a plugin to be lazy-loaded
    --   - options: table  = a plugin options
    setup = function (plugin, options)
    end,
    -- a function to load the plugin after everything else has been setup
    --
    --   - plugin: table = a plugin to be loaded
    load = function (plugin)
    end
  }

  -- a function to be called before setup plugins
  M.pre_setup = function ()
  end

  -- a function to handle plugin setup
  --
  -- this function will be called individually for each plugin
  --
  -- if your backend rather needs a list of plugins, you could simply store
  --   each plugin configurations and use 'post_setup' hook to setup all
  --   the plugins instead
  M.setup = function (name, options)
  end

  -- a function to be called after setup plugins
  M.post_setup = function ()
  end

  return M
end

-- later in the plugin configurations
require('plug').setup {
  backend = my_backend {
    -- your backend options go here
  }
}
```
