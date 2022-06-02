-- extension for requiring variables
X.needs = function (options)
  local opts = options or {}
  vim.validate {
    delay_post = { opts.delay_post, 'n', true }
  }

  local function need_fulfilled(variables, set)
    if not set then
      return false
    end
    for k, v in pairs(set) do
      if variables[k] ~= v then
        return true
      end
    end
    return false
  end

  local function ensure_needs(ctx, plugin, is_lazy, perform_post)
    if not plugin.needs then
      return
    end

    local sets = { 'g', 'b', 'w', 't', 'v', 'env' }
    for _, set in pairs(sets) do
      if need_fulfilled(vim[set], plugin.needs[set]) then
        vim.defer_fn(perform_post, opts.delay_post or P.delay_post)
        return true
      end
    end
  end

  return function (hook)
    hook('plugin_post', ensure_needs)
  end
end
