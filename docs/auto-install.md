# Automatically install plug.nvim

To automatically setup plug.nvim without a need to manually download the file,
simply add the following snippet to your `init.lua` file.

```lua
-- plug.nvim use 'packages' to load itself up. To load plug.nvim through
--   'runtimepath', change 2 lines below to this instead
--
--   local config_home = vim.fn.stdpath('config')
--   local plug_path = config_home .. '/lua/plug.lua'
local pack_site = vim.fn.stdpath('data') .. '/site/pack'
local plug_path = pack_site .. '/plug/start/plug.nvim/lua/plug.lua'
local plug_url = 'https://raw.githubusercontent.com/spywhere/plug.nvim/main/plug.lua'

if vim.fn.filereadable(vim.fn.expand(plug_path)) == 0 then
  if vim.fn.executable('curl') == 0 then
    -- curl not installed, skip the config
    print('cannot install plug.nvim, curl is not installed')
    return
  end
  vim.cmd(
    'silent !curl -fLo ' .. plug_path .. ' --create-dirs ' .. plug_url
  )
  -- only required if you have plug.nvim configured as 'start'
  --   since with 'opt' you would have to do the same every time as below
  vim.cmd('packadd! plug.nvim')
end

-- required if you have plug.nvim configured as 'opt'
-- vim.cmd('packadd! plug.nvim')

-- your plugin setup can go here
local plug = require('plug')

plug.setup {
  backend = '...',  -- your preferred backend goes here
  extensions = {
    -- also perform automatic installation for plugin manager and missing plugins
    plug.extension.auto_install {}
  }
}

-- your plugins go here

''
```

This will automatically download plug.nvim to the correct location. And it
will also performing a plugin installation for you as well.

For more options on how plug.nvim install plugin manager and missing plugins,
see [auto_install](/docs/extensions/auto-install.md) extension documentation.
