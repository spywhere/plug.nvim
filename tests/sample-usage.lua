vim.opt.runtimepath:append(vim.fn.getcwd())
local plug = require('plug')

print('------ #1 ------')
plug.setup {}
'user/repo'
{
  'user/repo2',
  option = {
    ['do'] = ':function'
  }
}
''
print('------ #2 ------')
plug.begin {}

plug.install 'user/repo'
plug.install {
  'user/repo2',
  option = {
    ['do'] = ':function'
  }
}

plug.ended()
print('------ #3 ------')
plug.setup(function (use)
  use 'user/repo'
  use {
    'user/repo2',
    option = {
      ['do'] = ':function'
    }
  }
end)
print('------ #4 ------')
plug.install 'preservim/nerdcommenter'
plug.install {
  'spywhere/tmux.nvim',
  config = function ()
    print('start')
    require('tmux').start()
  end
}

plug.setup {}
