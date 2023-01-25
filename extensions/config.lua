-- extension for per-plugin configurations
X.config = setmetatable({
  configs = {}
}, {
  __index = function (self, name)
    local fn = rawget(self, 'configs')[name]
    return function ()
      if fn then
        return fn()
      end
    end
  end,
  __call = function (self)
    local function configure_plugin(ctx, plugin)
      if type(plugin.config) ~= 'function' then
        return
      end

      plugin.config()
    end

    local function to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('config', 'conf')
        if type(plugin.config) ~= 'function' then
          return
        end

        local configs = rawget(self, 'configs')
        configs[plugin.name] = plugin.config
        options['conf'] = plugin.name
      end
    end

    return function (hook, ctx)
      if ctx.backend == 'vim-plug' then
        hook('plugin_post', configure_plugin)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', to_options(ctx))
      end
    end
  end
})
