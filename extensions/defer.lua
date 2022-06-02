-- extension for per-plugin deferred configurations
X.defer = function (options)
  local opts = options or {}
  vim.validate {
    defer_delay = { opts.defer_delay, 'n', true }
  }
  local function defer_plugin(ctx, plugin)
    if type(plugin.defer) == 'function' then
      vim.defer_fn(plugin.defer, 0)
    end

    if type(plugin.delay) == 'function' then
      vim.defer_fn(plugin.delay, opts.defer_delay or P.delay_post)
    end
  end

  return function (hook)
    hook('plugin_post', defer_plugin)
  end
end
