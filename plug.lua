__plug_nvim_fns = {}
local config_home = vim.fn.stdpath('config')
local i = {} -- internal
local I = {} -- vim-plug internal
local M = {} -- public
local X = {} -- extensions
local P = { -- private
  plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
  plug_path = config_home .. '/autoload/plug.vim',
  sync_install = 'PlugInstall --sync | q',
  plugin_dir = nil, -- use vim-plug default
  plugs = {},
  lazy = {},
  hooks = {},
  ext_context = {},
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

  P.auto('VimEnter', P.sync_install)
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

P.priority_sorter = function (plugin_a, plugin_b)
  local a_priority = plugin_a.priority or 0
  local b_priority = plugin_b.priority or 0
  return a_priority < b_priority
end

P.for_each = function (fn)
  for _, plugin in ipairs(P.plugs) do
    fn(plugin)
  end
end

P.auto = function (event, expression)
  vim.api.nvim_exec(table.concat({
    'augroup __plug_nvim__',
    'autocmd!',
    string.format(
      'autocmd %s * %s',
      event, expression
    ),
    'augroup end'
  }, '\n'), false)
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

P.dispatch = function (event, ...)
  if not P.hooks[event] then
    return
  end

  for _, listener in ipairs(P.hooks[event]) do
    local result = listener(P.ext_context, ...)
    if result ~= nil then
      return result
    end
  end
end

P.ext_dispatch = function (event, ...)
  return P.dispatch(event..'.ext', ...)
end

P.hook = function (event, listener)
  if not P.hooks[event] then
    P.hooks[event] = {}
  end
  table.insert(P.hooks[event], listener)
end

P.load = function (plugin)
  local options = plugin.options or {}

  if plugin.lazy then
    options.on = {}
    table.insert(P.lazy, plugin)
  end

  local perform_post = function ()
    vim.defer_fn(function () P.post(plugin, false) end, P.delay_post)
  end
  options = P.dispatch('plugin_options', options, perform_post) or options

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

  P.dispatch('plugin_post', plugin, perform_post)
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
      extension(P.hook, P.ext_dispatch)
    end
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

  -- TODO: Idea
  --   detect if plugin name is 'junegunn/vim-plug' then
  --   perform a vim-plug upgrade if needed
  plugin_options.name = name
  plugin_options = P.dispatch('plugin', plugin_options) or plugin_options

  local skip = false
  if type(plugin_options.skip) == 'function' then
    skip = plugin_options.skip()
  elseif type(plugin_options.skip) == 'boolean' then
    skip = plugin_options.skip
  end
  if skip then
    return
  end

  plugin_options.identifier = vim.fn.fnamemodify(name, ':t:s?\\.git$??')
  table.insert(P.plugs, plugin_options)
end

M.ended = function ()
  P.plugs = P.dispatch('plugin_collected', P.plugs) or P.plugs

  -- process pre-setup
  --   perform before vim-plug installation to allow custom function to
  --   dictate how vim-plug should behave
  P.dispatch('pre_setup', P.plugs)
  if P.dispatch('setup', P.plugs) == false then
    return
  end

  if P.plugin_dir then
    I.begin(P.plugin_dir)
  else
    I.begin()
  end
  P.for_each(P.load)
  I.ended()

  P.for_each(P.post)

  if next(P.lazy) then
    vim.defer_fn(P.schedule_lazy(), P.lazy_delay)
  end
  P.dispatch('done')

  P.plugs = {}
end

M.setup = function (opts, fn)
  local is_fn = type(opts) == 'function'
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

X.__install_missing_plugins = function ()
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

-- extension for requiring variables
X.needs = function (options)
  local opts = options or {}
  vim.validate {
    delay_post = { opts.delay_post, 'n', true }
  }
  local function ensure_needs(ctx, plugin, perform_post)
    if plugin.needs then
      local needs_fulfilled = true
      for _, v in ipairs(plugin.needs) do
        if vim.g[v] ~= 1 then
          needs_fulfilled = false
        end
      end

      if not needs_fulfilled then
        vim.defer_fn(perform_post, opts.delay_post or P.delay_post)
        return
      end
    end
  end

  return function (hook)
    hook('plugin_post', ensure_needs)
  end
end

-- extension for per-plugin configurations
X.config = function ()
  local function configure_plugin(ctx, plugin)
    if not plugin.config then
      return
    end

    plugin.config({
      installed = function ()
        return I.is_plugin_installed(plugin.identifier)
      end,
      loaded = function ()
        return I.is_plugin_loaded(plugin.identifier)
      end
    })
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
    if plugin.delay then
      vim.defer_fn(plugin.delay, opts.defer_delay or P.delay_post)
    end

    if plugin.defer then
      vim.defer_fn(plugin.defer, 0)
    end
  end

  return function (hook)
    hook('plugin_post', defer_plugin)
  end
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
      print('install failed')
      return
    end
  end

  local function post_installation(dispatch)
    return function (ctx)
      if opts.missing then
        P.auto('VimEnter', 'lua require("plug").extension.__install_missing_plugins()')
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

  local function inject_post_setup(ctx, options, perform_post)
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

  return function (hook, dispatch)
    hook('setup', installation)
    hook('plugin_options', inject_post_setup)
    hook('done', post_installation(dispatch))
  end
end

M.extension = X

return M
