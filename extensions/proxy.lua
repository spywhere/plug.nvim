-- extension for proxy plugin configurations to plugin manager's options
X.proxy = function (opts)
  local notify = false
  local function proxy(map)
    return function (_, options, _, plugin)
      for from_key, to in pairs(map) do
        local from = from_key

        if type(from) ~= 'string' then
          from = to
        end

        if
          type(to) == 'string' or
          (type(to) == 'function' and type(from) == 'string')
        then
          P.proxy_key(plugin, options, from, to)
        elseif not notify then
          notify = true
          local from_type = 'One of the key in proxy mappings'

          if type(from) == 'string' then
            from_type = string.format('Proxy mappings for \'%s\'', from)
          end

          vim.notify(string.format(
            '[%s] %s has a value of type \'%s\' instead of \'string\'',
            'plug.nvim',
            from_type,
            type(to)
          ), vim.log.levels.ERROR)
        end
      end
    end
  end

  return function (hook, ctx)
    local map = opts or {}

    if type(opts) == 'function' then
      map = map(ctx.backend)
    end

    if type(map) ~= 'table' then
      vim.notify(string.format(
        '[%s] Proxy mappings has a type \'%s\' instead of \'table\'',
        'plug.nvim',
        type(map)
      ), vim.log.levels.ERROR)
      return
    end

    hook('plugin_options', proxy(map))
  end
end
