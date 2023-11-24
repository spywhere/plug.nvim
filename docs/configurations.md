# Configurations

There are little to none configurations available for the plugin itself.
However, the power of this plugin will reside in the extensions its included.

```lua
-- depends on how you pick your setup, you can just pass the configurations
--   table to the setup / begin call
{
  -- a plugin manager backend, see the supported backends above
    -- by default plug.nvim will not pick any
  backend = nil,
  -- a delay in milliseconds before loading a lazy loaded plugins
  lazy_delay = 100,
  -- a delay in milliseconds between each lazy loaded plugin
  lazy_interval = 10,
  -- a delay in milliseconds before performing a post installation setup
  delay_post = 5,
  -- extensions to be use, set to empty table to not using any
  extensions = {
    -- see Extensions section below for available extensions
    --   and how to build one yourself!

    -- To automatically install plugin manager and missing plugins, use
    -- require('plug').extension.auto_install {}
  }
}
```

For backend and extension configurations, check out one of these

- [Backends](/docs/backends)
- [Extensions](/docs/extensions)

# Upgrade

To manually upgrade only plug.nvim, use `:lua PlugUpgrade()`.

To manually upgrade only, refers to the plugin manager documentations.

## vim-plug Injection (Deprecated)

plug.nvim can inject itself into vim-plug upgrade process, this is to allow
plug.nvim to perform an upgrade to both plug.nvim and vim-plug in a single
step.

To let plug.nvim inject the upgrade, you need to setup plug.nvim as one of
your plugin list.

```lua
require('plug').setup {}

-- name must be exact, but could be in any position
--   any plugin option will be ignored
'spywhere/plug.nvim'

''
```

Once you have the plugin setup, plug.nvim will create a command abbreviation
for `:PlugUpgrade`. So when you run `:PlugUpgrade`, it will perform both
plug.nvim and vim-plug upgrade automatically.

To manually upgrade only vim-plug in this case, use `: PlugUpgrade`.
