B['vim-plug'] = function (ctx)
  local config = vim.fn.stdpath('config')
  local M = {
    plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
    plug_path = config .. '/autoload/plug.vim',
  }

  local plug = function (name)
    return function (...)
      return vim.fn['plug#'..name](...)
    end
  end

  M.is_installed = function ()
    return vim.fn.filereadable(vim.fn.expand(M.plug_path)) ~= 0
  end

  M.install = function ()
    -- curl is not found
    if vim.fn.executable('curl') == 0 then
      return false
    end

    vim.cmd(
      'silent !curl -fLo ' .. M.plug_path .. ' --create-dirs ' .. M.plug_url
    )

    return true
  end

  M.lazy = {
    setup = function (_, options)
      options.on = {}
    end,
    load = plug'load'
  }

  M.pre_setup = function ()
    if ctx then
      return plug'begin'(ctx)
    else
      return plug'begin'()
    end
  end

  M.setup = function (name, options)
    options[true] = vim.types.dictionary
    plug''(name, options)
  end

  M.post_setup = plug'end'

  return M
end
