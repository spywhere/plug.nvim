P.priority_sorter = function (plugin_a, plugin_b)
  local a_priority = plugin_a.priority or 0
  local b_priority = plugin_b.priority or 0
  return a_priority < b_priority
end

-- extension for supporting plugin loading priority
X.priority = function ()
  local function sort_priority(ctx, plugs)
    table.sort(plugs, P.priority_sorter)
    return plugs
  end

  return function (hook)
    hook('plugin_collected', sort_priority)
  end
end
