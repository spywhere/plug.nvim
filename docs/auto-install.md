# Auto install plug.nvim

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

-- require('plug')
-- ...
```

This will automatically download the plug.nvim to the correct location. And if
you configured plug.nvim to also perform an automatic installation of
vim-plug, it will also performing those installation for you as well.
