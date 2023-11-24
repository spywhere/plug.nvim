P.priority_sorter = function (key)
  return function (plugin_a, plugin_b)
    local a_priority = plugin_a[key] or 0
    local b_priority = plugin_b[key] or 0
    return a_priority < b_priority
  end
end

P.reorder_sequence = function (key, plugins)
  local output = {}
  local container = {}

  local hold = function (name)
    local containment = container[name]

    if not containment then
      container[name] = #output + 1
    end
  end
  local insert = function (plugin)
    local containment = container[plugin.id]

    if containment == nil then
      table.insert(output, plugin)
    elseif containment ~= true then
      table.insert(output, containment, plugin)
    end

    container[plugin.id] = true
  end

  for _, plugin in ipairs(plugins) do
    local afters = plugin[key]

    if afters and type(afters) ~= 'table' then
      afters = { afters }
    end

    if afters then
      for _, after in ipairs(afters) do
        hold(after)
      end
    end

    insert(plugin)
  end

  return output
end

-- extension for supporting plugin loading priority
X.priority = function (options)
  local opts = options or {}
  vim.validate {
    priority = { opts.priority, 's', true },
    after = { opts.after, 's', true }
  }
  opts = vim.tbl_extend('keep', opts, {
    priority = 'priority',
    after = 'after'
  })

  local function sort_priority(ctx, plugs)
    if opts.priority and opts.priority ~= '' then
      table.sort(plugs, P.priority_sorter(opts.priority))
    end
    if opts.after and opts.after ~= '' then
      return P.reorder_sequence(opts.after, plugs)
    end
    return plugs
  end

  return function (hook)
    hook('plugin_collected', sort_priority)
  end
end
