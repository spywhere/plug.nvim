-- extension for per-plugin configurations
X.config = function ()
  local function configure_plugin(ctx, plugin)
    if type(plugin.config) ~= 'function' then
      return
    end

    plugin.config()
  end

  local function to_options(_, options, _, plugin)
    options['config'] = plugin.config
  end

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' then
      hook('plugin_post', configure_plugin)
    else
      hook('plugin_options', to_options)
    end
  end
end
