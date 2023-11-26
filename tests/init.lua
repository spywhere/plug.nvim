vim.cmd('packadd! plug.nvim')

local plug = require('plug')

plug.setup {
  backend = plug.backend {},
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
