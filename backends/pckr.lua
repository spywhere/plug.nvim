B.pckr = function (ctx)
  local loaders = {}
  local M = {
    name = 'pckr.nvim',
    pckr_path = vim.fn.stdpath('data') .. '/pckr/pckr.nvim',
    pckr_url = 'https://github.com/lewis6991/pckr.nvim',
    context = {
      install_command = function ()
        require('pckr').sync()
      end
    }
  }

  M.is_installed = function ()
    return not not vim.loop.fs_stat(M.pckr_path)
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(string.format(
      'silent !git clone --filter=blob:none %s %s'
      , M.pckr_url, M.pckr_path
    ))

    return true
  end

  M.lazy = {
    setup = function (plugin, options)
      if options.cond then
        -- already have a custom loader, skip lazy loading
        return
      end
      options.cond = function (load_plugin)
        if not loaders[plugin.name] then
          loaders[plugin.name] = load_plugin
        end
      end
    end,
    load = function (plugin)
      if loaders[plugin] then
        loaders[plugin]()
      end
    end
  }

  M.pre_setup = function ()
    vim.opt.rtp:prepend(M.pckr_path)

    return require('pckr').setup(ctx)
  end

  M.setup = function (name, options)
    options[1] = name
    require('pckr').add(options)
  end

  return M
end
B['pckr.nvim'] = B.pckr
