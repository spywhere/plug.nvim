-- extension for supporting pre-loading setup
X.skip = function ()
  local function skip_plugin(ctx, plugin)
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
    return function (_, options, _, plugin)
      if plugin.skip == nil then
        return
      end

      options[name] = skip_plugin(_, plugin) == match
    end
  end

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' then
      hook('plugin', skip_plugin)
    elseif ctx.backend == 'packer.nvim' then
      hook('plugin_options', proxy_to_options('disable', false))
    elseif ctx.backend == 'lazy.nvim' then
      hook('plugin_options', proxy_to_options('enabled'))
    end
  end
end
