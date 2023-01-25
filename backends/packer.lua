B['packer.nvim'] = function (ctx)
  local M = {
    packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim',
    packer_url = 'https://github.com/wbthomason/packer.nvim',
    context = {
      install_command = function ()
        require('packer').sync()
      end
    }
  }

  M.is_installed = function ()
    return vim.fn.empty(vim.fn.glob(M.packer_path)) == 0
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(
      'silent !git clone --depth 1 ' .. M.packer_url .. ' ' .. M.packer_path
    )

    return true
  end

  -- M.lazy = {
  --   setup = function (_, options)
  --     options.on = {}
  --   end,
  --   load = plug'load'
  -- }

  M.pre_setup = function ()
    vim.cmd('packadd packer.nvim')

    local packer = require('packer')
    packer.init(ctx)
    packer.reset()
    return packer
  end

  M.setup = function (name, options)
    options[1] = name
    require('packer').use(options)
  end

  return M
end
