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

To upgrade plug.nvim, use `:lua PlugUpgrade()`.

To upgrade plugin manager backend, refers to the plugin manager documentations.
