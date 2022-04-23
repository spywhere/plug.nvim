# plug.nvim

_This plugin still under development_

An extensible plugin manager wrap on top of
[vim-plug](https://github.com/junegunn/vim-plug) in pure lua.

Thus plugin is not a plugin manager, so vim-plug will either need to install
manually or configured to be automatically install (default behaviour).

## Table Of Contents

* [Features](#features)
* [Installation](#installation)
* [Getting Started](#getting-started)
* [Configurations](#configurations)
* [Extensions](#extensions)
* [Contributes](#contributes)
* [License](#license)

## Features

This plugin will behave with the exact same set of features as vim-plug.
Only with the ability to extends its behaviour.

So with some built-in configurations, you could achieve...

- vim-plug automatic installation
- Automatic installation of missing plugins
- Plugin loading priority
- Per-plugin configuration closure
- Defers setup
- Global variable requirements

## Installation

Simply download
[plug.lua](https://raw.githubusercontent.com/spywhere/plug.nvim/main/plug.lua)
and put it in `stdpath('config') .. '/lua/plug.lua'`.

Alternatively, you could automate the process by running one command.
Just like vim-plug!

```sh
curl -fLo ~/.config/nvim/lua/plug.lua --create-dirs https://raw.githubusercontent.com/spywhere/plug.nvim/main/plug.lua
```

For even more automatic, check out
[how to automatic install plug.nvim](docs/auto-install.md).

## Getting Started

plug.nvim gives you an ability to configure the plugin in 3 different ways so
you can choose the one that suit your workflow best.

### Setup 1

```lua
require('plug').setup {
  -- plug.nvim configurations go here
}

-- a simple installation of a plugin
--   the format is exact to that in vim-plug
'user/repo'

'https://github.com/user/repo.git'

-- to install a plugin with options, use map instead
{
  'user/repo',
  options = {
    -- vim-plug options for the plugin go here
    ['do'] = ':Function'
  }
}

-- !! IMPORTANT !! Be sure to kept an empty string last to allow plug.nvim
--   to set itself up!
''
```

### Setup 2

```lua
local plug = require('plug')

plug.begin {
  -- plug.nvim configurations go here
}

-- a simple installation of a plugin
--   the format is exact to that in vim-plug
plug.install 'user/repo'

plug.install 'https://github.com/user/repo.git'

-- to install a plugin with options, use map instead
plug.install {
  'user/repo',
  options = {
    -- vim-plug options for the plugin go here
    ['do'] = ':Function'
  }
}

-- 'end' is a reserved word in lua, so use 'ended' instead
plug.ended()
```

### Setup 3

```lua
local plug = require('plug')

-- use the following if you want to use the default configurations
--   plug.setup(function (use)
--     ... plugins go here ...
--   end)
plug.setup(
  {
    -- plug.nvim configurations go here
  },
  function (use)
    -- a simple installation of a plugin
    --   the format is exact to that in vim-plug
    use 'user/repo'

    use 'https://github.com/user/repo.git'

    -- to install a plugin with options, use map instead
    use {
      'user/repo',
      options = {
        -- vim-plug options for the plugin go here
        ['do'] = ':Function'
      }
    }
  end
)
```

## Configurations

There are little to none configurations available for the plugin itself.
However, the power of this plugin will reside in the extensions its included.

```lua
-- depends on how you pick your setup, you can just pass the configurations
-- map to the setup / begin call
{
  -- plugin installation directory, this will be passed to vim-plug begin
  --   call. Default to the vim-plug default location.
  plugin_dir = nil,
  -- a delay in milliseconds before loading a lazy loaded plugins
  lazy_delay = 100,
  -- a delay in milliseconds between each lazy loaded plugin
  lazy_interval = 10,
  -- a delay in milliseconds before performing a post installation setup
  delay_post = 5,
  -- extensions to be use, set to empty map to not using any
  extensions = {
    -- see Extensions section below for available extensions
    --   and how to build one yourself!
    require('plug').extension.auto_install {}
  }
}
```

## Extensions

plug.nvim comes bundled with some set of extensions

- [`auto_install`](docs/extensions/auto-install.md): Automatic vim-plug
installation and auto installation for missing plugins
- [`config`](docs/extensions/config.md): Add a support for per-plugin configuration closure
- [`defer`](docs/extensions/defer.md): Add a support for per-plugin deferred configurations
- [`needs`](docs/extensions/needs.md): Add a support for global variable requirements for plugin
- [`priority`](docs/extensions/priority.md): Add a support for plugin loading priority
- [`setup`](docs/extensions/setup.md): Add a support for plugin pre-loading setup
- [`skip`](docs/extensions/skip.md): Add a support for conditionally plugin skipping

Note that some extensions will dictate how plug.nvim will process the setup.
You can refer to each extension configurations and setup by following a link
of the extension.

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

or

```sh
nvim -u tests/init.lua
```

To test automatic installation, use

```sh
make testrun-auto
```

or

```sh
nvim -u tests/auto.lua
```

## License

Released under the [MIT License](LICENSE)
