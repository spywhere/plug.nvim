# Installation

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
[how to automatic install plug.nvim](/docs/auto-install.md) right from your
`init.lua` file.

# Getting Started

plug.nvim gives you an ability to configure the plugin in 4 different ways so
you can choose the one that suit your workflow best (and ease the migration).

## Setup 1 - Recommended Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

local plug = require('plug')
plug.setup {
  backend = plug.backend.your_preferred_backend {  -- your preferred backend goes here
    -- your backend configurations can go here
  },
  -- the rest of plug.nvim configurations can go here

  -- recommended extensions
  extensions = {
      -- perform automatic installation of plugin manager and any missing plugins
      plug.extension.auto_install {}
  },
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

## Setup 2 - vim-plug Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

local plug = require('plug')
-- pass a reference to a variable so it resemble more
--   like a vim-plug
local Plug = plug.install

plug.begin {
  backend = plug.backend.your_preferred_backend {  -- your preferred backend goes here
    -- your backend configurations can go here
  },
  -- the rest of plug.nvim configurations can go here

  -- recommended extensions
  extensions = {
      -- perform automatic installation of plugin manager and any missing plugins
      plug.extension.auto_install {}
  },
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

## Setup 3 - packer.nvim Way

```lua
-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

local plug = require('plug')

plug.setup(
  {
    backend = plug.backend.your_preferred_backend {  -- your preferred backend goes here
      -- your backend configurations can go here
    },
    -- the rest of plug.nvim configurations can go here

    -- recommended extensions
    extensions = {
        -- perform automatic installation of plugin manager and any missing plugins
        plug.extension.auto_install {}
    },
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

## Setup 4 - API Way

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
  backend = plug.backend.your_preferred_backend {  -- your preferred backend goes here
    -- your backend configurations can go here
  },
  -- the rest of plug.nvim configurations can go here

  -- recommended extensions
  extensions = {
      -- perform automatic installation of plugin manager and any missing plugins
      plug.extension.auto_install {}
  },
}
```

# Next

Now that you have configured your setup, try checking out one of these

- [Configurations and Upgrade](/docs/configurations.md)
- [Backends](/docs/backends)
- [Extensions](/docs/extensions)
