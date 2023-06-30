# plug.nvim

An extensible layer for plugin managers in pure lua.

Thus this plugin is not a plugin manager, so a plugin manager backend will
either need to install manually or configured to be automatically install.

## Table Of Contents

* [Features](#features)
* [Breaking Changes](#breaking-changes)
* [Supported Backends](#supported-backends)
* [Installation](#installation)
* [Getting Started](#getting-started)
* [Configurations](#configurations)
* [Upgrade](#upgrade)
* [Extensions](#extensions)
* [Contributes](#contributes)
* [License](#license)

## Features

This plugin will behave with the exact same set of its backend plugin manager.
Only with the ability to extends its behaviour.

So with some built-in configurations, you could achieve...

- Plugin manager automatic installation
- Automatic installation of missing plugins
- Per-plugin configuration closure
- Plugin and variable requirements
- Plugin loading priority and sequencing
- Defers setup
- Conditionally install a plugin
- [And more...](#extensions)

## Breaking Changes

### 2023-07-01

- (requirement) `backend`: backend is no longer an optional nor
opinionated by default
- (deprecated) `plugin_dir`: backend specific configurations are now named
as `options`. For `vim-plug` backend, simply rename `plugin_dir` to
`options` should set a plugin directory correctly.

### Prior updates

- Latest version before supporting multiple backend, check out
[vim-plug](https://github.com/spywhere/plug.nvim/tree/vim-plug)
- Latest version supporting neovim v0.5.1, check out
[nvim-0.5.1](https://github.com/spywhere/plug.nvim/tree/nvim-0.5.1)

## Supported Backends

With plug.nvim flexible design, you can switch your plugin manager backend to
your liking. You can even adopt a new fancy plugin manager by simply switch
the backend[^1], making plugin manager migration much less painful.

- [vim-plug](https://github.com/junegunn/vim-plug)
- [packer.nvim](https://github.com/wbthomason/packer.nvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)

[^1]: Any plugin `options` that are set will required a manual migration

## Installation

Requires neovim v0.7.0 or later.

If you wish to use plug.nvim with older neovim version (v0.5.1 up to v0.6.1),
check out [nvim-0.5.1](https://github.com/spywhere/plug.nvim/tree/nvim-0.5.1)
branch. Do note that nvim-0.5.1 branch is for migration purpose only so the
code will not be maintained.

Simply download
[plug.lua](https://raw.githubusercontent.com/spywhere/plug.nvim/main/plug.lua)
and put it in `stdpath('data') .. '/site/pack/plug/start/plug.nvim/lua/plug.lua'`.

Alternatively, you could automate the process by running one command.

```sh
curl -fLo ~/.local/share/nvim/site/pack/plug/start/plug.nvim/lua/plug.lua --create-dirs https://raw.githubusercontent.com/spywhere/plug.nvim/main/plug.lua
```

For even more automatic, check out
[how to automatic install plug.nvim](docs/auto-install.md) right from your
`init.lua` file.

## Getting Started

plug.nvim gives you an ability to configure the plugin in 4 different ways so
you can choose the one that suit your workflow best.

### Setup 1 - Recommended Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

require('plug').setup {
  backend = '...',  -- your preferred backend goes here
  -- the rest of plug.nvim configurations can go here
}

-- a simple installation of a plugin
--   the format is exact to that in its plugin manager backend
'user/repo'

'https://github.com/user/repo.git'

-- to install a plugin with options, use table instead
{
  'user/repo',
  -- set to `true`, to lazily load this plugin
  lazy = true,
  options = {
    -- plugin manager options for the plugin go here
    ['do'] = ':Function'
  }
}

-- !! IMPORTANT !! Be sure to kept an empty string last to allow plug.nvim
--   to set itself up!
''
```

### Setup 2 - vim-plug Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

local plug = require('plug')
-- pass a reference to a variable so it resemble more
--   like a vim-plug
local Plug = plug.install

plug.begin {
  backend = '...',  -- your preferred backend goes here
  -- the rest of plug.nvim configurations can go here
}

-- a simple installation of a plugin
--   the format is exact to that in its plugin manager backend
Plug 'user/repo'

-- or can use plug.install() directly without a helper
--   function needed
Plug 'https://github.com/user/repo.git'

-- to install a plugin with options, use table instead
Plug {
  'user/repo',
  options = {
    -- plugin manager options for the plugin go here
    ['do'] = ':Function'
  }
}

-- or use a regular function call with 2 arguments
Plug(
  'user/repo', {
    -- set to `true`, to lazily load this plugin
    lazy = true,
    options = {
    -- plugin manager options for the plugin go here
      ['do'] = ':Function'
    }
  }
)

-- 'end' is a reserved word in lua, so use 'ended' instead
plug.ended()
```

### Setup 3 - packer.nvim Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

local plug = require('plug')

-- use the following if you want to use the default configurations
--   plug.setup(function (use)
--     ... plugins go here ...
--   end)
plug.setup(
  {
    backend = '...',  -- your preferred backend goes here
    -- the rest of plug.nvim configurations can go here
  },
  function (use)
    -- a simple installation of a plugin
    --   the format is exact to that in its plugin manager backend
    use 'user/repo'

    use 'https://github.com/user/repo.git'

    -- to install a plugin with options, use table instead
    use {
      'user/repo',
      options = {
        -- plugin manager options for the plugin go here
        ['do'] = ':Function'
      }
    }

    -- or use a regular function call with 2 arguments
    use(
      'user/repo', {
        -- set to `true`, to lazily load this plugin
        lazy = true,
        options = {
          -- plugin manager options for the plugin go here
          ['do'] = ':Function'
        }
      }
    )
  end
)
```

### Setup 4 - API Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

local plug = require('plug')

-- these `plug.install` calls can be performed from anywhere

-- a simple installation of a plugin
--   the format is exact to that in its plugin manager backend
plug.install 'user/repo'

plug.install 'https://github.com/user/repo.git'

-- to install a plugin with options, use table instead
plug.install {
  'user/repo',
  options = {
    -- plugin manager options for the plugin go here
    ['do'] = ':Function'
  }
}

-- or use a regular function call with 2 arguments
plug.install(
  'user/repo', {
    -- set to `true`, to lazily load this plugin
    lazy = true,
    options = {
      -- plugin manager options for the plugin go here
      ['do'] = ':Function'
    }
  }
)

-- then at the very last step, call `plug.setup`
plug.setup {
  backend = '...',  -- your preferred backend goes here
  -- the rest of plug.nvim configurations can go here
}
```

## Configurations

There are little to none configurations available for the plugin itself.
However, the power of this plugin will reside in the extensions its included.

```lua
-- depends on how you pick your setup, you can just pass the configurations
--   table to the setup / begin call
{
  -- a plugin manager backend, see the supported backends above
    -- by default plug.nvim will not pick any
  backend = '...',
  -- options to be passed to the plugin manager backend
    -- for vim-plug, it will be use for `plug#begin()`
    -- for packer.nvim, it will be use for `packer.init()`
  options = nil,
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

## Upgrade

To manually upgrade only plug.nvim, use `:lua PlugUpgrade()`.

To manually upgrade only, refers to the plugin manager documentations.

### vim-plug Injection

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

## Extensions

plug.nvim comes bundled with some set of extensions

- [`auto_install`](docs/extensions/auto-install.md): Automatic plugin manager
installation and auto installation for missing plugins
- [`config`](docs/extensions/config.md): Add a support for per-plugin configuration closure
- [`defer`](docs/extensions/defer.md): Add a support for per-plugin deferred configurations
- [`needs`](docs/extensions/needs.md): Add a support for global variable requirements for plugin
- [`priority`](docs/extensions/priority.md): Add a support for plugin loading priority and sequencing
- [`requires`](docs/extensions/requires.md): Add a support for plugin requirements
- [`setup`](docs/extensions/setup.md): Add a support for plugin pre-loading setup
- [`skip`](docs/extensions/skip.md): Add a support for conditionally plugin skipping

Note that some extensions will dictate how plug.nvim will process the setup.
You can refer to each extension configurations and setup by following a link
of the extension.

## Extension Compatibility

Each built-in extensions will have its compatibility matrix to indicate the
compatibility with each backends. The following are the explanation of each
compatibility meaning

- Proxy to `name`: The extension will simply used the value as-is. Similar to
how the plugin will be configured natively
- Polyfilled: The extension will make a workaround in order to support such
feature for the plugin manager
- Untested: The feature might work for certain backends, required some testing

### Extension Authoring

If you wish to implement your own extension, feel free to check out
[how to build your own extension](docs/extensions/api.md). This should give
you an overview of how extension works as well as what is available to you.

## Contributes

During the development, you can use the following command to automatically
setup a working configurations to test the plugin...

```sh
make testrun
```

To test automatic installation, use

```sh
make testrun-auto
```

To preview the code generation, use

```sh
make preview
```

To manually generate the output code, use

```sh
make compile
```

## License

Released under the [MIT License](LICENSE)
