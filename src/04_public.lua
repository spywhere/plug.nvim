M.begin = function (options)
  local opts = options or {}

  vim.validate {
    plugin_dir = { opts.plugin_dir, 's', true },
    lazy_delay = { opts.lazy_delay, 'n', true },
    lazy_interval = { opts.lazy_interval, 'n', true },
    delay_post = { opts.delay_post, 'n', true },
    extensions = { opts.extensions, 't', true }
  }

  P.plugin_dir = opts.plugin_dir
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
    for _, extension in ipairs(opts.extensions) do
      if type(extension) == 'function' then
        extension(P.hook)
      elseif type(extension) == 'table' and extension.name then
        local name = extension.name
        if not P.extensions[name] then
          P.extensions[name] = true
          extension.entry(P.hook, P.ext_dispatch(name))
        end
      end
    end
  end

  if not next(P.plugs) then
    P.use_api = false
  end
end

M.install = function (plugin, options)
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

  -- if plugin is this plugin, then inject upgrade function
  if name == 'spywhere/plug.nvim' then
    P.inject_cmds = true
    return
  end

  definition.name = name
  if not P.use_api then
    definition = P.raw_dispatch('plugin', true, definition)

    if definition == false then
      return
    end
  end

  definition.identifier = vim.fn.fnamemodify(name, ':t:s?\\.git$??')
  table.insert(P.plugs, definition)
end

M.ended = function ()
  if vim.fn.has('nvim') == 0 then
    print('plug.nvim only supported in neovim')
    return
  elseif vim.fn.has('nvim-0.7.0') == 0 then
    print('plug.nvim requires neovim v0.7.0 or later')
    return
  end

  if P.use_api then
    P.for_each(function (plugin)
      local new_plugin = P.raw_dispatch('plugin', true, plugin)

      if new_plugin == false then
        return
      end

      table.insert(P.plugs, new_plugin)
    end, true)
  end
  P.plugs = P.dispatch('plugin_collected', P.plugs)

  -- process pre-setup
  --   perform before vim-plug installation to allow custom function to
  --   dictate how vim-plug should behave
  P.dispatch('pre_setup', P.plugs)
  if P.raw_dispatch('setup', true, P.plugs) == false then
    return
  end

  if P.plugin_dir then
    I.begin(P.plugin_dir)
  else
    I.begin()
  end
  P.for_each(P.load, true)
  I.ended()

  P.for_each(P.post)

  if next(P.lazy) then
    vim.defer_fn(P.schedule_lazy, P.lazy_delay)
  end

  P.setup_functions()

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

      return next(plugins)
    end
  end)
end
