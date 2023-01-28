-- extension for supporting pre-loading setup
X.setup = setmetatable({
  setups = {}
}, {
  __index = function (self, name)
    local fn = rawget(self, 'setups')[name]
    return function()
      if fn then
        return fn()
      end
    end
  end,
  __call = function (self)
    local function setup()
      P.for_each(
        function (plugin)
          if type(plugin.setup) == 'function' then
            plugin.setup()
          end
        end
      )
    end

    local function to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('setup', 'preconfigure', 'setup')
        if type(plugin.setup) ~= 'function' then
          return
        end

        local setups = rawget(self, 'setups')
        setups[plugin.name] = plugin.setup
        options['preconfigure'] = plugin.name
      end
    end

    return function (hook, ctx)
      if ctx.backend == 'vim-plug' then
        hook('pre_setup', setup)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', to_options(ctx))
      end
    end
  end
})
