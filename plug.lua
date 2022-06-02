__plug_nvim_fns = {}
local config_home = vim.fn.stdpath('config')
local i = {} -- internal
local I = {} -- vim-plug internal
local M = {} -- public
local X = {} -- extensions
local P = { -- private
  plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
  plug_path = config_home .. '/autoload/plug.vim',
  plug_nvim_url = 'https://github.com/spywhere/plug.nvim.git',
  plug_nvim_path = config_home .. '/lua/plug.lua',
  sync_install = 'PlugInstall --sync | q',
  plugin_dir = nil, -- use vim-plug default
  plugs = {},
  lazy = {},
  hooks = {},
  extensions = {},
  ext_context = {},
  use_api = true,
  inject_cmds = false,
  lazy_delay = 100,
  lazy_interval = 10,
  delay_post = 5
}

i.increment = (function ()
  local i = 0
  return function ()
    i = i + 1
    return i
  end
end)()

i.wrap = function (value)
  if type(value) == 'table' then
    return value
  else
    return { value }
  end
end

i.recurse = function (fn)
  return (function (next) return next(next) end)(fn)
end

i.generator = function (fn, default)
  return i.recurse(function (next)
    return function (value)
      return fn(next(next), value)
    end
  end)(default)
end

local plug = function (name)
  return function (...)
    return vim.fn['plug#'..name](...)
  end
end
I.begin = plug'begin'
I.ended = plug'end'
I.plug = plug''
I.load = plug'load'

I.is_installed = function ()
  return vim.fn.filereadable(vim.fn.expand(P.plug_path)) ~= 0
end

I.install = function ()
  -- curl is not found
  if vim.fn.executable('curl') == 0 then
    return false
  end

  vim.cmd(
    'silent !curl -fLo ' .. P.plug_path .. ' --create-dirs ' .. P.plug_url
  )

  return true
end

I.is_plugin_installed = function (name)
  if not vim.g.plugs or vim.g.plugs[name] == nil then
    return false
  end
  return vim.fn.isdirectory(vim.g.plugs[name].dir) == 1
end

I.is_plugin_loaded = function (name)
  if not vim.g.plugs or vim.g.plugs[name] == nil then
    return false
  end
  local plugin_path = vim.g.plugs[name].dir
  plugin_path = string.gsub(plugin_path, '[/\\]*$', '')
  return vim.fn.stridx(vim.o.rtp, plugin_path) >= 0
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
    P.fn({ name = name }, fn)

    if P.inject_cmds then
      P.inject_command(name, string.format('call %s()', name))
    end
  end
end

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
  local plugin_options = {}

  if type(name) == 'string' then
    plugin_options.options = options
  else
    plugin_options = {}
    for k, v in pairs(name) do
      if type(k) == 'string' then
        plugin_options[k] = v
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

  plugin_options.name = name
  if not P.use_api then
    plugin_options = P.raw_dispatch('plugin', true, plugin_options)

    if plugin_options == false then
      return
    end
  end

  plugin_options.identifier = vim.fn.fnamemodify(name, ':t:s?\\.git$??')
  table.insert(P.plugs, plugin_options)
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

P.install_missing_plugins = function ()
  local is_plugin_missing = function (plugin)
    return vim.fn.isdirectory(plugin.dir) == 0
  end

  local plugins = vim.tbl_values(vim.g.plugs)
  local missing_plugins = vim.tbl_filter(is_plugin_missing, plugins)
  if not next(missing_plugins) then
    return
  end

  vim.cmd(P.sync_install)
end

-- extension for auto-install vim-plug and missing plugins
X.auto_install = function (options)
  local opts = options or {}
  vim.validate {
    plug = { opts.plug, 'b', true },
    missing = { opts.missing, 'b', true },
    post_install_delay = { opts.post_install_delay, 'n', true }
  }
  opts = vim.tbl_extend('keep', opts, {
    plug = true,
    missing = true,
    post_install_delay = 100
  })

  local function installation(ctx)
    ctx.is_installed = I.is_installed()

    -- attempt to install vim-plug automatically,
    --   or skip all plugins if it's not installed
    if not ctx.is_installed and (not opts.plug or not I.install()) then
      -- TODO: report error
      return false
    end

    if opts.missing then
      P.auto('VimEnter', P.sync_install)
    end
  end

  local function post_installation(dispatch)
    return function (ctx)
      if opts.missing then
        P.auto('VimEnter', P.install_missing_plugins)
      end
      if ctx.is_installed then
        dispatch('has_installed')
      else
        dispatch('first_install')
      end
    end
  end

  local has_prefix = function (string, prefix)
    return string.find(string, prefix, 1, true) == 1
  end

  local function inject_post_setup(ctx, options, perform_post, plugin)
    local original_do = options['do']

    options['do'] = vim.funcref(P.fn(
      {
        'info'
      },
      function (info)
        -- post install
        if info.status == 'installed' then
          perform_post()
          if plugin.post_install then
            vim.defer_fn(plugin.post_install, opts.post_install_delay)
          end
        end

        -- perform original action
        if type(original_do) == 'userdata' or type(original_do) == 'function' then
          original_do(info)
        elseif type(original_do) == 'string' then
          assert(
            has_prefix(original_do, ':'),
            'passing "do" as command line is not supported here'
          )
          vim.cmd(string.sub(original_do, 2))
        end
      end
    ))
    return options
  end

  return {
    name = 'auto_install',
    entry = function (hook, dispatch)
      hook('setup', installation)

      if opts.missing then
        hook('plugin_options', inject_post_setup)
      end

      hook('done', post_installation(dispatch))
    end
  }
end

-- extension for per-plugin configurations
X.config = function ()
  local function configure_plugin(ctx, plugin)
    if type(plugin.config) ~= 'function' then
      return
    end

    plugin.config()
  end

  return function (hook)
    hook('plugin_post', configure_plugin)
  end
end

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

-- extension for supporting pre-loading setup
X.setup = function ()
  local function setup()
    P.for_each(
      function (plugin)
        if type(plugin.setup) == 'function' then
          plugin.setup()
        end
      end
    )
  end

  return function (hook)
    hook('pre_setup', setup)
  end
end

-- extension for supporting pre-loading setup
X.skip = function ()
  local function skip_plugin(ctx, plugin)
    local skip = false
    if type(plugin.skip) == 'function' then
      skip = plugin.skip()
    elseif type(plugin.skip) == 'boolean' then
      skip = plugin.skip
    end
    if skip then
      return false
    end
  end

  return function (hook)
    hook('plugin', skip_plugin)
  end
end

M.extension = X

return M
