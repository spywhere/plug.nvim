B.vim_plug = function (ctx)
  local config = vim.fn.stdpath('data')
  local M = {
    name = 'vim-plug',
    plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
    plug_path = config .. '/site/autoload/plug.vim',
    context = {
      install_command = 'PlugInstall --sync | q'
    }
  }

  local plug = function (name)
    return function (...)
      return vim.fn['plug#'..name](...)
    end
  end

  M.context.has_missing_plugins = function ()
    local is_plugin_missing = function (plugin)
      return vim.fn.isdirectory(plugin.dir) == 0
    end

    local plugins = vim.tbl_values(vim.g.plugs)
    local missing_plugins = vim.tbl_filter(is_plugin_missing, plugins)
    return next(missing_plugins)
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
    load = function (plugin)
      return plug'load'(vim.fn.fnamemodify(plugin.name, ':t:s?\\.git$??'))
    end
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
B['vim-plug'] = B.vim_plug
