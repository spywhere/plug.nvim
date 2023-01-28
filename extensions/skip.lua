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

  local function to_options(_, options, _, plugin)
    if plugin.skip == nil then
      return
    end

    options.disable = skip_plugin(_, plugin) == false
  end

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' then
      hook('plugin', skip_plugin)
    elseif ctx.backend == 'packer.nvim' then
      hook('plugin_options', to_options)
    end
  end
end
