# Automatically install plug.nvim

To automatically setup plug.nvim without a need to manually download the file,
simply add the following snippet to your `init.lua` file.

```lua
local config_home = vim.fn.stdpath('config')
local plug_path = config_home .. '/lua/plug.lua'
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
end

-- your plugin setup can go here
local plug = require('plug')

plug.setup {
  extensions = {
    -- also perform automatic installation for vim-plug and missing plugins
    plug.extension.auto_install {}
  }
}

-- your plugins go here

''
```

This will automatically download plug.nvim to the correct location. And it
will also performing a plugin installation for you as well.

For more options on how plug.nvim install vim-plug and missing plugins, see
[auto_install](extensions/auto-install.md) extension documentation.
