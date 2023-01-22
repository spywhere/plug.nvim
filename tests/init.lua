vim.opt.runtimepath:append(vim.fn.getcwd())
local plug = require('plug')

plug.setup {
  options = vim.fn.getcwd() .. '/plugged',
  extensions = {
    plug.extension.auto_install {},
    plug.extension.config {}
  }
}
'preservim/nerdcommenter'
{
  'spywhere/tmux.nvim',
  config = function ()
    print('start')
    require('tmux').start()
  end
}
''
