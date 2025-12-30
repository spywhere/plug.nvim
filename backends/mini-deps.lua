B.deps = function (ctx)
  local M = {
    name = 'mini.deps',
    deps_path = vim.fn.stdpath('data') .. '/site/pack/deps/opt/mini.nvim',
    deps_url = 'https://github.com/nvim-mini/mini.deps'
  }

  M.is_installed = function ()
    return not not vim.loop.fs_stat(M.deps_path)
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(
      'silent !git clone --filter=blob:none ' .. M.deps_url .. ' ' .. M.deps_path
    )

    return true
  end

  M.pre_setup = function ()
    vim.cmd('packadd mini.nvim | helptags ALL')

    return require('mini.deps').setup(ctx)
  end

  M.setup = function (name, options)
    if name then
      options.source = name
    end
    require('mini.deps').add(options)
  end

  return M
end
B['mini.deps'] = B.deps
