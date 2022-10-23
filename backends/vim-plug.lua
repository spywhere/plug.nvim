B['vim-plug'] = function (ctx)
  local M = {
    name = 'vim-plug'
  }

  local plug = function (name)
    return function (...)
      return vim.fn['plug#'..name](...)
    end
  end

  M.is_installed = function ()
    return vim.fn.filereadable(vim.fn.expand(P.plug_path)) ~= 0
  end

  M.install = function ()
    -- curl is not found
    if vim.fn.executable('curl') == 0 then
      return false
    end

    vim.cmd(
      'silent !curl -fLo ' .. P.plug_path .. ' --create-dirs ' .. P.plug_url
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
    if ctx.plugin_dir then
      return plug'begin'(ctx.plugin_dir)
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
