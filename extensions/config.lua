-- extension for per-plugin configurations
X.config = function ()
  local function configure_plugin(ctx, plugin)
    if type(plugin.config) ~= 'function' then
      return
    end

    plugin.config()
  end

  return function (hook)
    hook('plugin_post', configure_plugin)
  end
end
