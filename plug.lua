------------------------------------------
-- this file is automatically generated --
--        do not edit directly          --
--    build: 13 Oct 2022 20:27:56       --
------------------------------------------
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
  plugs_container = {},
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

P.print = function (format, ...)
  vim.cmd('redraw')
  vim.notify(string.format(format, ...), vim.log.levels.INFO)
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

P.functions = {
  PlugUpgrade = function ()
    if vim.fn.filereadable(vim.fn.expand(P.plug_nvim_path)) == 0 then
      -- plug.nvim is loaded but not found, assumming it's on development
      --   environment
      P.print(
        'plug.nvim cannot be found on default location, skipping upgrade'
      )
      return
    end

    P.print('Downloading the latest version of plug.nvim')

    local tmp = vim.fn.tempname()
    local new_file = tmp .. '/plug.lua'

    local output = vim.fn.system({
      'git', 'clone', '--depth', '1',
      P.plug_nvim_url, tmp,
      [true] = vim.types.array
    })
    if vim.v.shell_error ~= 0 then
      P.print('Error upgrading plug.nvim: %s', output)
      return
    end

    local sha256 = function (path)
      return vim.fn.sha256(table.concat(vim.fn.readfile(path), '\n'))
    end

    if sha256(P.plug_nvim_path) == sha256(new_file) then
      P.print('plug.nvim is already up-to-date')
    else
      vim.fn.rename(P.plug_nvim_path, P.plug_nvim_path .. '.old')
      vim.fn.rename(new_file, P.plug_nvim_path)
      P.print('plug.nvim has been upgraded')
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

M.install = function (...)
  local definition = P.to_plugin(...)

  -- if plugin is this plugin, then inject upgrade function
  if definition.name == 'spywhere/plug.nvim' then
    P.inject_cmds = true
    return
  end

  P.add_plugin(definition, not P.use_api and P.plugin_mutator or nil)
end

M.ended = function ()
  if vim.fn.has('nvim') == 0 then
    print('plug.nvim only supported in neovim')
    return
  elseif vim.fn.has('nvim-0.7.0') == 0 then
    print('plug.nvim requires neovim v0.7.0 or later')
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

P.execute_shell = function (command, callback)
  local luv = vim.loop

  local handle
  local timer
  local output = {}

  local stdout = luv.new_pipe()
  local stderr = luv.new_pipe()

  local options = command.options or {}
  options.stdio = { nil, stdout, stderr }

  local cmd = table.remove(command.cmd, 1)
  options.args = command.cmd

  handle = luv.spawn(
    cmd,
    options,
    function(code, signal)
      output.code = code
      output.signal = signal
      handle:close()
      if timer then
        timer:stop()
        timer:close()
      end

      local check = luv.new_check()
      luv.check_start(check, function ()
        for _, pipe in pairs(options.stdio) do
          if not luv.is_closing(pipe) then
            return
          end
        end
        luv.check_stop(check)
        vim.defer_fn(function ()
          callback(output)
        end, 0)
      end)
    end
  )

  local function pipe_output(pipe, target, err_target)
    luv.read_start(pipe, function (err, data)
      if err and err_target then
        output[err_target] = string.format(
          '%s%s',
          output[err_target] or '',
          data
        )
      end

      if data == nil then
        luv.read_stop(pipe)
        luv.close(pipe)
      else
        output[target] = string.format('%s%s', output[target] or '', data)
      end
    end)
  end

  pipe_output(stdout, 'stdout')
  pipe_output(stderr, 'stderr')

  if command.timeout then
    timer = luv.new_timer()
    timer:start(command.timeout * 1000, 0, function ()
      timer:stop()
      timer:close()

      if not luv.is_active(handle) then
        return
      end

      output.signal = 'sigint'
      luv.process_kill(handle, output.signal)
      handle:close()
      for _, pipe in pairs(options.stdio) do
        luv.close(pipe)
      end
      output.code = -9999
      callback(output)
    end)
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

  local function inject_post_setup(_, options, perform_post, plugin)
    local original_do = options['do']

    options['do'] = function (info)
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
        if has_prefix(original_do, ':') then
          vim.cmd(string.sub(original_do, 2))
        else
          local plug = vim.g.plugs[info.name]

          assert(
            plug,
            string.format(
              '[plug.nvim] Plugin "%s" is unexpectedly not found',
              info.name
            )
          )

          local shell = os.getenv('SHELL') or vim.o.shell
          local flag = string.find(shell, 'cmd.exe$') and '/c' or '-c'
          local command = {
            cmd = {
              shell, flag, original_do
            },
            options = {
              cwd = plug.dir
            }
          }
          P.execute_shell(command, function (ctx)
            if ctx.stderr then
              vim.notify(string.format(
                '[%s] Plugin "%s" has an error during post installation:\n%s',
                'plug.nvim',
                plugin.name,
                ctx.stderr
              ), vim.log.levels.ERROR)
            end
            if ctx.stdout then
              vim.notify(string.format(
                '[%s] Plugin "%s" has an output during post installation:\n%s',
                'plug.nvim',
                plugin.name,
                ctx.stdout
              ), vim.log.levels.INFO)
            end
          end)
        end
      end
    end
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
    local containment = container[plugin.name]

    if containment == nil then
      table.insert(output, plugin)
    elseif containment ~= true then
      table.insert(output, containment, plugin)
    end

    container[plugin.name] = true
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

-- extension for supporting plugin requirements
X.requires = function ()
  local function require_mutator(plugin, containment)
    plugin = vim.tbl_deep_extend('force', plugin, containment.plugin)

    if plugin.optional then
      plugin.optional = nil
    end

    return plugin
  end

  local function require_plugins(ctx, plugin, install_plugin)
    if plugin.optional then
      return false
    end

    local requires = plugin.requires or {}
    if type(requires) ~= 'table' then
      requires = { requires }
    end

    for _, req in ipairs(requires) do
      install_plugin(require_mutator, req)
    end
  end

  return function (hook)
    hook('plugin', require_plugins)
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
