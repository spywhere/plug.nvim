B.packer = function (ctx)
  local handlers = {}
  local M = {
    name = 'packer.nvim',
    packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim',
    packer_url = 'https://github.com/wbthomason/packer.nvim',
    context = {
      install_command = function ()
        require('packer').sync()
      end,
      setup_handler = function (ext, name, kind)
        local keyname = ext .. '.' .. name .. '.' .. (kind or 'config')
        if handlers[keyname] then
          return
        end

        require('packer').set_handler(name, function (_, plugin, value)
          local call = string.format(
            'require(\'plug\').extension.%s[\'%s\'](\'%s\')',
            ext, value, name
          )

          if not kind or kind == 'config' then
            if type(plugin.config) == 'table' then
              table.insert(plugin.config, call)
            else
              plugin.config = { call }
            end
          else
            plugin[kind] = call
          end
        end)

        handlers[keyname] = true
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

  M.lazy = {
    key = 'opt'
  }

  M.pre_setup = function ()
    vim.cmd('packadd packer.nvim')

    local packer = require('packer')
    packer.init(ctx)
    packer.reset()

    M.setup('wbthomason/packer.nvim', {
      opt = true
    })

    return packer
  end

  M.setup = function (name, options)
    if name then
      options[1] = name
    end
    require('packer').use(options)
  end

  return M
end
B['packer.nvim'] = B.packer
