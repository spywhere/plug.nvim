M.begin = function (options)
  local opts = options or {}

  vim.validate {
    backend = { opts.backend, { 's', 't' }, true },
    lazy_delay = { opts.lazy_delay, 'n', true },
    lazy_interval = { opts.lazy_interval, 'n', true },
    delay_post = { opts.delay_post, 'n', true },
    extensions = { opts.extensions, 't', true },

    update_branch = { opts.update_branch, 's', true }
  }

  if type(opts.backend) == 'table' then
    P.backend = opts.backend
  elseif not opts.backend then
    local backends = vim.tbl_keys(B)
    table.sort(backends)
    P.print(
      'Backend is required. Supported backends: %s',
      table.concat(backends, ', ')
    )
    return
  else
    -- deprecated
    local backendfn = B[opts.backend]

    if not backendfn then
      P.print('Unsupported backend: %s', opts.backend)
      return
    end

    local is_ok, backend = pcall(backendfn, opts.options)
    if not is_ok then
      P.print(
        'Unable to use a backend \'%s\':\n%s',
        opts.backend, vim.inspect(error)
      )
      return
    else
      P.backend = backend
      P.print(
        '[Deprecated] Backend setting through string is now deprecated'
      )
    end
  end

  if
    type(P.backend) ~= 'table' or
    type(P.backend.name) ~= 'string' or
    type(P.backend.setup) ~= 'function'
  then
    P.backend = nil
    if type(opts.backend) == 'table' then
      P.print(
        'Backend %s is not a valid backend',
        opts.backend.name and string.format(
          '\'%s\'', opts.backend.name
        ) or 'given'
      )
    else
      P.print('Backend \'%s\' is not a valid backend', opts.backend)
    end
    return
  end

  if opts.lazy_delay then
    P.lazy_delay = opts.lazy_delay
  end
  if opts.lazy_interval then
    P.lazy_interval = opts.lazy_interval
  end
  if opts.delay_post then
    P.delay_post = opts.delay_post
  end

  if opts.extensions then
    local context = P.backend.context or {}
    context.backend = P.backend.name
    for _, extension in ipairs(opts.extensions) do
      if type(extension) == 'function' then
        extension(P.hook, context)
      elseif type(extension) == 'table' and extension.name then
        local name = extension.name
        if not P.extensions[name] then
          P.extensions[name] = true
          extension.entry(P.hook, P.ext_dispatch(name), context)
        end
      end
    end
  end

  if not next(P.plugs) then
    P.use_api = false
  end

  if opts.update_branch then
    P.plug_nvim_branch = opts.update_branch
  end
end

M.install = function (...)
  local definition = P.to_plugin(...)

  -- if plugin is this plugin, then inject upgrade function
  if definition.name == 'spywhere/plug.nvim' then
    P.inject_cmds = true
    P.print(
      '[Deprecated] Upgrade command injection is no longer support'
    )
    return
  end

  P.add_plugin(definition, not P.use_api and P.plugin_mutator or nil)
end

M.ended = function ()
  if not P.backend then
    return
  elseif vim.fn.has('nvim') == 0 then
    P.rawprint('plug.nvim only supported in neovim')
    return
  elseif vim.fn.has('nvim-0.7.0') == 0 then
    P.rawprint('plug.nvim requires neovim v0.7.0 or later')
    return
  end

  P.setup_functions()

  if P.use_api then
    P.plugs_container = {}
    P.for_each(function (p) P.add_plugin(p, P.plugin_mutator) end, true)
  end
  P.plugs_container = {}
  P.plugs = P.dispatch('plugin_collected', P.plugs)

  -- process pre-setup
  --   perform before plugin manager installation to allow custom function to
  --   dictate how plugin manager should behave
  P.dispatch('pre_setup', P.plugs)
  if P.raw_dispatch('setup', true, P.plugs) == false then
    return
  end

  if P.backend.pre_setup then
    P.backend.pre_setup()
  end
  P.for_each(P.load, true)
  if P.backend.post_setup then
    P.backend.post_setup()
  end

  if P.raw_dispatch('post_setup', true, P.plugs) == false then
    return
  end

  P.for_each(P.post)

  if next(P.lazy) then
    vim.defer_fn(P.schedule_lazy, P.lazy_delay)
  end

  P.setup_injections()

  P.dispatch('done')

  P.plugs = {}
end

M.setup = function (opts, fn)
  local is_fn = type(opts) == 'function'

  if not is_fn and next(P.plugs) then
    M.begin(opts)
    return M.ended()
  end

  if is_fn or type(fn) == 'function' then
    M.begin(not is_fn and opts or nil)

    if is_fn then
      opts(M.install)
    else
      fn(M.install)
    end

    return M.ended()
  end

  M.begin(opts)
  return i.generator(function (next)
    return function (plugin)
      if plugin == nil or plugin == '' or #plugin == 0 then
        return M.ended()
      end

      M.install(plugin)

      return next()
    end
  end)
end
