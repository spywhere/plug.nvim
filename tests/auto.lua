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
end

local plug = require('plug')

plug.setup {
  options = vim.fn.getcwd() .. '/plugged',
  extensions = {
    plug.extension.auto_install {},
    plug.extension.config {}
  }
}
-- enable self-upgrade
'spywhere/plug.nvim'
'preservim/nerdcommenter'
{
  'spywhere/tmux.nvim',
  config = function ()
    print('start')
    require('tmux').start()
  end
}
''
