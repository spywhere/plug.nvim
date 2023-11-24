B.lazy = function (ctx)
  local M = {
    name = 'lazy.nvim',
    plugins = {},
    lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim',
    lazy_url = 'https://github.com/folke/lazy.nvim.git'
  }

  M.is_installed = function ()
    return not not vim.loop.fs_stat(M.lazy_path)
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(
      'silent !git clone --filter=blob:none ' .. M.lazy_url .. ' --branch=stable ' .. M.lazy_path
    )

    return true
  end

  M.lazy = {
    key = 'lazy'
  }

  M.pre_setup = function ()
    vim.opt.rtp:prepend(M.lazy_path)
  end

  M.setup = function (name, options)
    if name then
      options[1] = name
    end
    table.insert(M.plugins, options)
  end

  M.post_setup = function ()
    require('lazy').setup(M.plugins, ctx)
  end

  return M
end
B['lazy.nvim'] = B.lazy
