P.rawprint = function (format, ...)
  vim.cmd('redraw')
  vim.notify(string.format(format, ...), vim.log.levels.INFO)
end

P.print = function (format, ...)
  return P.rawprint(string.format('plug.nvim: %s', format), ...)
end

P.for_each = function (fn, mutable)
  local plugs = vim.tbl_extend('force', {}, P.plugs)
  if mutable then
    P.plugs = {}
  end
  for _, plugin in ipairs(plugs) do
    fn(plugin)
  end
end

P.auto = function (event, func)
  vim.api.nvim_create_autocmd(event, {
    group = vim.api.nvim_create_augroup('__plug_nvim__', {}),
    callback = func
  })
end

P.inject_command = function (cmd, expr)
  local expression = {
    'cnoreabbrev',
    cmd,
    '<c-r>=(getcmdtype()==\':\'',
    '&&',
    'getcmdpos()==1',
    '?',
    string.format('\'%s \\| %s\'', expr, cmd),
    ':',
    string.format('\'%s\'', cmd),
    ')<cr>'
  }

  vim.api.nvim_exec(table.concat(expression, ' '), false)
end

P.has_hook = function (event)
  return P.hooks[event] and next(P.hooks[event])
end

P.raw_dispatch = function (event, keep_false, value, ...)
  if not P.hooks[event] then
    return value
  end

  local new_value = value
  for _, handler in ipairs(P.hooks[event]) do
    local result = handler(P.ext_context, new_value, ...)
    if result == false then
      if keep_false then
        return false
      else
        return new_value
      end
    elseif result ~= nil then
      new_value = result
    end
  end
  return new_value
end

P.dispatch = function (event, ...)
  return P.raw_dispatch(event, false, ...)
end

P.ext_dispatch = function (name)
  return function (event, ...)
    return P.dispatch(name .. '.' .. event, ...)
  end
end

P.hook = function (event, handler)
  if not P.hooks[event] then
    P.hooks[event] = {}
  end
  table.insert(P.hooks[event], handler)
end

P.load = function (plugin)
  local options = plugin.options or {}

  if P.backend.lazy and P.backend.lazy.key then
    options[P.backend.lazy.key] = plugin.lazy
  end

  if plugin.lazy and P.backend.lazy then
    if P.backend.lazy.setup then
      P.backend.lazy.setup(plugin, options)
    end
    options.lazy = nil
    table.insert(P.lazy, plugin)
  else
    table.insert(P.plugs, plugin)
  end

  local perform_post = function ()
    vim.defer_fn(function () P.post(plugin, false) end, P.delay_post)
  end
  options = P.dispatch('plugin_options', options, perform_post, plugin)

  P.backend.setup(plugin.name, options)
end

P.post = function (plugin, is_lazy)
  local perform_post = function ()
    vim.defer_fn(function () P.post(plugin, is_lazy) end, P.delay_post)
  end

  P.dispatch('plugin_post', plugin, is_lazy, perform_post)
end

P.schedule_lazy = function ()
  local delay = 0

  if P.backend.lazy then
    for _, plugin in ipairs(P.lazy) do
      vim.defer_fn(function ()
        if P.backend.lazy.load then
          P.backend.lazy.load(plugin.identifier)
        end

        vim.defer_fn(function ()
          P.post(plugin, true)
        end, P.delay_post)
      end, delay)
      delay = delay + P.lazy_interval
    end
  end

  P.lazy = {}
end

P.functions = {
  PlugUpgrade = function ()
    local plug_nvim_path = vim.fn.fnamemodify(
      debug.getinfo(1, 'S').source:sub(2), ':p'
    )

    if vim.fn.filereadable(vim.fn.expand(plug_nvim_path)) == 0 then
      -- plug.nvim is loaded but not found, assumming it's on development
      --   environment
      P.rawprint(
        'plug.nvim cannot be found on default location, skipping upgrade'
      )
      return
    end

    if vim.fn.filereadable(vim.fn.expand(P.old_plug_nvim_path)) ~= 0 then
      -- plug.nvim is found on old location, mark it as old
      P.rawprint(
        'plug.nvim has adopt packages (see \':h packages\'), ' ..
        'updating the previous installation as old'
      )
      vim.fn.rename(P.old_plug_nvim_path, P.old_plug_nvim_path .. '.old')
    end

    P.rawprint('Downloading the latest version of plug.nvim')

    local tmp = vim.fn.tempname()
    local new_file = tmp .. '/plug.lua'

    local clone_cmd = {
      'git', 'clone', '--depth', '1'
    }

    if P.plug_nvim_branch then
      table.insert(clone_cmd, '--branch')
      table.insert(clone_cmd, P.plug_nvim_branch)
    end

    table.insert(clone_cmd, P.plug_nvim_url)
    table.insert(clone_cmd, tmp)
    clone_cmd[true] = vim.types.array

    local output = vim.fn.system(clone_cmd)
    if vim.v.shell_error ~= 0 then
      P.rawprint('Error upgrading plug.nvim: %s', output)
      return
    end

    local sha256 = function (path)
      return vim.fn.sha256(table.concat(vim.fn.readfile(path), '\n'))
    end

    if sha256(plug_nvim_path) == sha256(new_file) then
      P.rawprint('plug.nvim is already up-to-date')
    else
      vim.fn.rename(plug_nvim_path, plug_nvim_path .. '.old')
      vim.fn.rename(new_file, plug_nvim_path)
      P.rawprint('plug.nvim has been upgraded')
    end
  end
}

P.setup_functions = function ()
  for name, fn in pairs(P.functions) do
    _G[name] = fn
  end
end

P.setup_injections = function ()
  if P.inject_cmds then
    for name, _ in pairs(P.functions) do
      P.inject_command(name, string.format('lua %s()', name))
    end
  end
end

P.to_plugin = function (plugin, options)
  local name = plugin
  local definition = {}

  if type(name) == 'string' then
    definition.options = options
  else
    definition = {}
    for k, v in pairs(name) do
      if type(k) == 'string' then
        definition[k] = v
      else
        name = v
      end
    end

    if type(name) ~= 'string' then
      name = definition.name or definition.url or definition.dir
    end
  end

  definition.name = name
  definition.identifier = vim.fn.fnamemodify(name, ':t:s?\\.git$??')
  return definition
end

P.plugin_mutator = function (plugin)
  P.plugs_container[plugin.name] = {
    plugin = plugin
  }

  plugin = P.raw_dispatch('plugin', true, plugin, P.hold_plugin)

  if plugin == false then
    return
  end

  return plugin
end

P.add_plugin = function (plugin, mutator)
  local containment = P.plugs_container[plugin.name]

  local new_plugin = plugin
  if mutator then
    new_plugin = mutator(plugin)
  end

  if containment and containment.mutator then
    new_plugin = containment.mutator(
      plugin, {
        plugin = containment.plugin,
        hold = containment.index and true or false
      }
    )

    if not new_plugin then
      return
    end

    if containment.index then
      P.plugs[containment.index] = new_plugin
    else
      table.insert(P.plugs, new_plugin)
    end
  elseif new_plugin and not containment then
    table.insert(P.plugs, new_plugin)
  else
    return
  end

  P.plugs_container[plugin.name] = {
    plugin = new_plugin
  }
end

P.hold_plugin = function (mutator, ...)
  local plugin
  if type(mutator) == 'function' then
    plugin = P.to_plugin(...)
  else
    plugin = P.to_plugin(mutator, ...)
    mutator = function (v) return v end
  end

  local containment = P.plugs_container[plugin.name]
  if containment then
    P.plugs_container[plugin.name].mutator = mutator
  end
  P.add_plugin(plugin)
  if not containment then
    P.plugs_container[plugin.name] = {
      plugin = plugin,
      index = #(P.plugs),
      mutator = mutator
    }
  end
end

P.proxy_key = function (plugin, options, from, to)
  if not plugin[from] then
    return
  end

  local value = plugin[from]
  local to_key = to or from
  if type(to_key) == 'function' then
    to_key = to_key(value)
  end
  if to_key == nil then
    return
  end
  options[to_key] = value
end

P.proxy_to_options = function (from, to)
  return function (_, options, _, plugin)
    return P.proxy_key(plugin, options, from, to)
  end
end
