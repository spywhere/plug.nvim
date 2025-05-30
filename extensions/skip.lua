-- extension for supporting pre-loading setup
X.skip = function (options)
  local opts = options or {}
  vim.validate {
    behavior = {
      opts.behavior,
      function (v)
        local behaviors = {
          'disable', 'remove'
        }
        return type(v) == 'string' and vim.list_contains(behaviors, v)
      end,
      true
    }
  }
  opts = vim.tbl_extend('keep', opts, {
    behavior = 'disable'
  })

  local function skip_plugin(_, plugin)
    local skip = false
    if type(plugin.skip) == 'function' then
      skip = plugin.skip()
    elseif type(plugin.skip) == 'boolean' then
      skip = plugin.skip
    end
    if skip then
      return false
    end
  end

  local function proxy_to_options(name, match)
    return function (_, plugin_options, _, plugin)
      if plugin.skip == nil then
        return
      end

      plugin_options[name] = skip_plugin(_, plugin) == match
    end
  end

  return function (hook, ctx)
    if opts.behavior == 'remove' then
      hook('plugin', skip_plugin)
      return
    end

    if ctx.backend == 'vim-plug' or ctx.backend == 'pckr.nvim' then
      hook('plugin', skip_plugin)
    elseif ctx.backend == 'packer.nvim' then
      hook('plugin_options', proxy_to_options('disable', false))
    elseif ctx.backend == 'lazy.nvim' then
      hook('plugin_options', proxy_to_options('enabled'))
    end
  end
end
