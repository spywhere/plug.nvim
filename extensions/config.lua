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

    local function handle_to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('config', 'conf')
        if type(plugin.config) ~= 'function' then
          return
        end

        local configs = rawget(self, 'configs')
        configs[plugin.id] = plugin.config
        options['conf'] = plugin.id
      end
    end

    return function (hook, ctx)
      if ctx.backend == 'vim-plug' then
        hook('plugin_post', configure_plugin)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', handle_to_options(ctx))
      elseif ctx.backend == 'lazy.nvim' or ctx.backend == 'pckr.nvim' then
        hook('plugin_options', P.proxy_to_options('config'))
      end
    end
  end
})
