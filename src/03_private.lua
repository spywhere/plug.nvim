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

P.call_for_fn = function (func, args)
  local call = { 'v:lua' }
  local index = i.increment()
  __plug_nvim_fns['_' .. index] = func
  local arguments = table.concat(i.wrap(args) or {}, ',')
  table.insert(call, '__plug_nvim_fns._' .. index .. '(' .. arguments .. ')')
  return table.concat(call, '.')
end

P.fn = function (fn_signature, fn_ref)
  local func = fn_ref
  local signature = fn_signature or {}
  if type(signature) == 'function' then
    func = signature
    signature = {}
  end
  local name = signature.name or string.format(
    '__plug_nvim_fn_%s',
    i.increment()
  )
  assert(type(name) == 'string', 'function name must be a string')
  assert(
    func,
    'callback function is required for function \'' .. name .. '\''
  )
  assert(
    type(func) == 'function',
    'callback function must be a function for function \'' .. name .. '\''
  )

  local params = {}
  local args = {}
  for k, v in pairs(signature) do
    if type(k) == 'number' and type(v) == 'string' then
      table.insert(params, v)
      table.insert(args, 'a:' .. v)
    end
  end
  local definition = {
    'function! ' .. name .. '(' .. table.concat(params, ',') ..')',
    'return ' .. P.call_for_fn(func, args),
    'endfunction'
  }
  vim.api.nvim_exec(table.concat(definition, '\n'), false)
  return name
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

  if plugin.lazy then
    options.on = {}
    options.lazy = nil
    table.insert(P.lazy, plugin)
  else
    table.insert(P.plugs, plugin)
  end

  local perform_post = function ()
    vim.defer_fn(function () P.post(plugin, false) end, P.delay_post)
  end
  options = P.dispatch('plugin_options', options, perform_post, plugin)

  options[true] = vim.types.dictionary
  I.plug(plugin.name, options)
end

P.post = function (plugin, is_lazy)
  if not I.is_plugin_installed(plugin.identifier) then
    return
  end

  local perform_post = function ()
    vim.defer_fn(function () P.post(plugin, is_lazy) end, P.delay_post)
  end

  P.dispatch('plugin_post', plugin, is_lazy, perform_post)
end

P.schedule_lazy = function ()
  local delay = 0

  for _, plugin in ipairs(P.lazy) do
    vim.defer_fn(function ()
      I.load(plugin.identifier)

      vim.defer_fn(function ()
        P.post(plugin, true)
      end, P.delay_post)
    end, delay)
    delay = delay + P.lazy_interval
  end

  P.lazy = {}
end

P.setup_functions = function ()
  local sha256 = function (path)
    return vim.fn.sha256(table.concat(vim.fn.readfile(path), '\n'))
  end

  local functions = {
    PlugUpgrade = function ()
      if vim.fn.filereadable(vim.fn.expand(P.plug_nvim_path)) == 0 then
        -- plug.nvim is loaded but not found, assumming it's on development
        --   environment
        print(
          'plug.nvim cannot be found on default location, skipping upgrade'
        )
        return
      end

      print('Downloading the latest version of plug.nvim')
      vim.cmd('redraw')

      local tmp = vim.fn.tempname()
      local new_file = tmp .. '/plug.lua'

      local output = vim.fn.system({
        'git', 'clone', '--depth', '1',
        P.plug_nvim_url, tmp,
        [true] = vim.types.array
      })
      if vim.v.shell_error ~= 0 then
        print('Error upgrading plug.nvim:', output)
        return
      end

      if sha256(P.plug_nvim_path) == sha256(new_file) then
        print('plug.nvim is already up-to-date')
      else
        vim.fn.rename(P.plug_nvim_path, P.plug_nvim_path .. '.old')
        vim.fn.rename(new_file, P.plug_nvim_path)
        print('plug.nvim has been upgraded')
      end
    end
  }

  for name, fn in pairs(functions) do
    _G[name] = fn

    if P.inject_cmds then
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
  end

  definition.name = name
  definition.identifier = vim.fn.fnamemodify(name, ':t:s?\\.git$??')
  return definition
end
