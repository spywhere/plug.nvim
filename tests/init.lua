vim.opt.runtimepath:append(vim.fn.getcwd())
local plug = require('plug')

plug.setup {
  backend = plug.backend.lazy {
    root = vim.fn.getcwd() .. '/lazy'
  },
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
