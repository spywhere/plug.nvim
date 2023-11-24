# Backends

With plug.nvim [flexible design](/docs/design-principles.md), you can switch
your plugin manager backend to your liking. You can even adopt a new fancy
plugin manager by simply switch the backend[^1], making plugin manager
migration much less painful.

[^1]: Any plugin `options` that are set will required a manual migration

- [lazy.nvim](https://github.com/folke/lazy.nvim): `require('plug').backend.lazy`
- [packer.nvim](https://github.com/wbthomason/packer.nvim): `require('plug').backend.packer`
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim): `require('plug').backend.pckr`
- [vim-plug](https://github.com/junegunn/vim-plug): `require('plug').backend.vim_plug`

Alternatively, its full name can also be used, though it is more verbose.

## Configure backend configurations

To configure your backend configurations, simply pass it through its function.

```lua
local plug = require('plug')
plug.setup {
  backend = plug.backend.your_preferred_backend {  -- your preferred backend goes here
    -- your backend configurations can go here
  },
  -- the rest of plug.nvim configurations can go here
}
```

Here are examples on various to configure your backend configurations

```lua
plug.setup {
  backend = plug.backend.plug(),  -- use default vim-plug config
  backend = plug.backend.packer(),  -- use default packer.nvim config
  backend = plug.backend.packer {  -- use a custom packer.nvim config
    auto_clean = false  -- don't clean unused plugins
  },
  backend = plug.backend.lazy {  -- use a custom lazy.nvim config
    root = '/tmp/nvim-plugins'  -- set plugin installation path
  },
}
```
