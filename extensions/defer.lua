-- extension for per-plugin deferred configurations
X.defer = setmetatable({
  defers = {},
  delays = {},
  delay_duration = 0
}, {
  __index = function (self, name)
    return function (kind)
      local fn = rawget(self, kind .. 's')[name]
      if fn then
        if kind == 'defer' then
          vim.defer_fn(fn, 0)
        else
          vim.defer_fn(fn, rawget(self, 'delay_duration'))
        end
      end
    end
  end,
  __call = function (self, options)
    local opts = options or {}
    vim.validate {
      defer_delay = { opts.defer_delay, 'n', true }
    }

    rawset(self, 'delay_duration', opts.defer_delay or P.delay_post)

    local function defer_plugin(ctx, plugin)
      if type(plugin.defer) == 'function' then
        vim.defer_fn(plugin.defer, 0)
      end

      if type(plugin.delay) == 'function' then
        vim.defer_fn(plugin.delay, rawget(self, 'delay_duration'))
      end
    end

    local function to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('defer', 'defer')
        ctx.setup_handler('defer', 'delay')

        if type(plugin.defer) == 'function' then
          local defers = rawget(self, 'defers')
          defers[plugin.id] = plugin.defer
          options['defer'] = plugin.id
        end

        if type(plugin.delay) == 'function' then
          local delays = rawget(self, 'delays')
          delays[plugin.id] = plugin.delay
          options['delay'] = plugin.id
        end
      end
    end

    return function (hook, ctx)
      if
        ctx.backend == 'vim-plug' or
        ctx.backend == 'lazy.nvim' or
        ctx.backend == 'pckr.nvim'
      then
        hook('plugin_post', defer_plugin)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', to_options(ctx))
      end
    end
  end
})
