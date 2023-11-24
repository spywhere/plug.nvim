------------------------------------------
-- this file is automatically generated --
--        do not edit directly          --
------------------------------------------
local build_checksum = "b9460cb76e666eeab3d5a2ecb4ff4d6883734baf2bfeb2446eb3c928c2b504e6"
local config_home = vim.fn.stdpath('config')
local i = {} -- internal
local M = {} -- public
local B -- backends
local X -- extensions
local P = { -- private
  plug_nvim_url = 'https://github.com/spywhere/plug.nvim.git',
  old_plug_nvim_path = config_home .. '/lua/plug.lua',
  plugs_container = {},
  plugs = {},
  lazy = {},
  hooks = {},
  extensions = {},
  ext_context = {},
  use_api = true,
  lazy_delay = 100,
  lazy_interval = 10,
  delay_post = 5
}

i.uuid = function ()
  local template = 'xxxx-yyyy-xxxx-yyyy'
  return string.gsub(template, '[xy]', function (c)
    return string.format(
      '%x',
      c == 'x' and math.random(0, 0xf) or math.random(8, 0xb)
    )
  end)
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

i.soft_table = function (fn)
  return setmetatable({}, {
    __index = function(self, k)
      local value = rawget(self, k)
      if not value then
        return fn(k)
      end
      return value
    end
  })
end

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
          P.backend.lazy.load(plugin)
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
      elseif type(v) == 'string' then
        name = v
      end
    end
  end

  local identifier = name
  if type(identifier) ~= 'string' then
    identifier = (
      definition.id or definition.name or definition.url or definition.dir or
      i.uuid()
    )
  end

  definition.name = name
  definition.id = identifier
  return definition
end

P.plugin_mutator = function (plugin)
  P.plugs_container[plugin.id] = {
    plugin = plugin
  }

  plugin = P.raw_dispatch('plugin', true, plugin, P.hold_plugin)

  if plugin == false then
    return
  end

  return plugin
end

P.add_plugin = function (plugin, mutator)
  local containment = P.plugs_container[plugin.id]

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

  P.plugs_container[plugin.id] = {
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

  local containment = P.plugs_container[plugin.id]
  if containment then
    P.plugs_container[plugin.id].mutator = mutator
  end
  P.add_plugin(plugin)
  if not containment then
    P.plugs_container[plugin.id] = {
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
    P.print('Expected a valid backend, got %s instead', type(opts.backend))
    return
  end

  if
    type(P.backend.name) ~= 'string' or
    type(P.backend.setup) ~= 'function'
  then
    P.backend = nil
    P.print(
      'Backend %s is not a valid backend',
      opts.backend.name and string.format(
        '\'%s\'', opts.backend.name
      ) or 'given'
    )
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

  -- if plugin is this plugin, do nothing and explain how to upgrade instead
  if definition.name == 'spywhere/plug.nvim' then
    P.print(
      'use \':lua PlugUpgrade()\' to upgrade plug.nvim'
    )
    return
  end

  P.add_plugin(definition, not P.use_api and P.plugin_mutator or nil)
end

M.ended = function ()
  if vim.fn.has('nvim') == 0 then
    P.rawprint('plug.nvim only supported in neovim')
    return
  elseif vim.fn.has('nvim-0.7.0') == 0 then
    P.rawprint('plug.nvim requires neovim v0.7.0 or later')
    return
  end

  P.setup_functions()

  if not P.backend then
    return
  end

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

B = i.soft_table(function (k) -- backends
  return function ()
    return {
      name = k
    }
  end
end)

B.lazy = function (ctx)
  local M = {
    name = 'lazy.nvim',
    plugins = {},
    lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim',
    lazy_url = 'https://github.com/folke/lazy.nvim.git'
  }

  M.is_installed = function ()
    return not not vim.loop.fs_stat(M.lazy_path)
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(
      'silent !git clone --filter=blob:none ' .. M.lazy_url .. ' --branch=stable ' .. M.lazy_path
    )

    return true
  end

  M.lazy = {
    key = 'lazy'
  }

  M.pre_setup = function ()
    vim.opt.rtp:prepend(M.lazy_path)
  end

  M.setup = function (name, options)
    if name then
      options[1] = name
    end
    table.insert(M.plugins, options)
  end

  M.post_setup = function ()
    require('lazy').setup(M.plugins, ctx)
  end

  return M
end
B['lazy.nvim'] = B.lazy

B.packer = function (ctx)
  local handlers = {}
  local M = {
    name = 'packer.nvim',
    packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim',
    packer_url = 'https://github.com/wbthomason/packer.nvim',
    context = {
      install_command = function ()
        require('packer').sync()
      end,
      setup_handler = function (ext, name, kind)
        local keyname = ext .. '.' .. name .. '.' .. (kind or 'config')
        if handlers[keyname] then
          return
        end

        require('packer').set_handler(name, function (_, plugin, value)
          local call = string.format(
            'require(\'plug\').extension.%s[\'%s\'](\'%s\')',
            ext, value, name
          )

          if not kind or kind == 'config' then
            if type(plugin.config) == 'table' then
              table.insert(plugin.config, call)
            else
              plugin.config = { call }
            end
          else
            plugin[kind] = call
          end
        end)

        handlers[keyname] = true
      end
    }
  }

  M.is_installed = function ()
    return vim.fn.empty(vim.fn.glob(M.packer_path)) == 0
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(
      'silent !git clone --depth 1 ' .. M.packer_url .. ' ' .. M.packer_path
    )

    return true
  end

  M.lazy = {
    key = 'opt'
  }

  M.pre_setup = function ()
    vim.cmd('packadd packer.nvim')

    local packer = require('packer')
    packer.init(ctx)
    packer.reset()

    M.setup('wbthomason/packer.nvim', {
      opt = true
    })

    return packer
  end

  M.setup = function (name, options)
    if name then
      options[1] = name
    end
    require('packer').use(options)
  end

  return M
end
B['packer.nvim'] = B.packer

B.pckr = function (ctx)
  local loaders = {}
  local M = {
    name = 'pckr.nvim',
    pckr_path = vim.fn.stdpath('data') .. '/pckr/pckr.nvim',
    pckr_url = 'https://github.com/lewis6991/pckr.nvim',
    context = {
      install_command = function ()
        require('pckr').sync()
      end
    }
  }

  M.is_installed = function ()
    return not not vim.loop.fs_stat(M.pckr_path)
  end

  M.install = function ()
    -- git is not found
    if vim.fn.executable('git') == 0 then
      return false
    end

    vim.cmd(string.format(
      'silent !git clone --filter=blob:none %s %s'
      , M.pckr_url, M.pckr_path
    ))

    return true
  end

  M.lazy = {
    setup = function (plugin, options)
      if options.cond then
        -- already have a custom loader, skip lazy loading
        return
      end
      options.cond = function (load_plugin)
        if not loaders[plugin.id] then
          loaders[plugin.id] = load_plugin
        end
      end
    end,
    load = function (plugin)
      if loaders[plugin.id] then
        loaders[plugin.id]()
      end
    end
  }

  M.pre_setup = function ()
    vim.opt.rtp:prepend(M.pckr_path)

    return require('pckr').setup(ctx)
  end

  M.setup = function (name, options)
    if name then
      options[1] = name
    end
    require('pckr').add(options)
  end

  return M
end
B['pckr.nvim'] = B.pckr

B.vim_plug = function (ctx)
  local config = vim.fn.stdpath('data')
  local M = {
    name = 'vim-plug',
    plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
    plug_path = config .. '/site/autoload/plug.vim',
    context = {
      install_command = 'PlugInstall --sync | q'
    }
  }

  local plug = function (name)
    return function (...)
      return vim.fn['plug#'..name](...)
    end
  end

  M.context.has_missing_plugins = function ()
    local is_plugin_missing = function (plugin)
      return vim.fn.isdirectory(plugin.dir) == 0
    end

    local plugins = vim.tbl_values(vim.g.plugs)
    local missing_plugins = vim.tbl_filter(is_plugin_missing, plugins)
    return next(missing_plugins)
  end

  M.is_installed = function ()
    return vim.fn.filereadable(vim.fn.expand(M.plug_path)) ~= 0
  end

  M.install = function ()
    -- curl is not found
    if vim.fn.executable('curl') == 0 then
      return false
    end

    vim.cmd(
      'silent !curl -fLo ' .. M.plug_path .. ' --create-dirs ' .. M.plug_url
    )

    return true
  end

  M.lazy = {
    setup = function (_, options)
      options.on = {}
    end,
    load = function (plugin)
      return plug'load'(vim.fn.fnamemodify(plugin.name, ':t:s?\\.git$??'))
    end
  }

  M.pre_setup = function ()
    if ctx then
      return plug'begin'(ctx)
    else
      return plug'begin'()
    end
  end

  M.setup = function (name, options)
    options[true] = vim.types.dictionary
    plug''(name, options)
  end

  M.post_setup = plug'end'

  return M
end
B['vim-plug'] = B.vim_plug

X = i.soft_table(function (k) -- extensions
  P.print('Extension \'%s\' is not available', k)
  return function ()
  end
end)

P.run_install_plugins = function(install_context, first_install)
  local command = install_context.install_command
  if not command then
    return function () end
  end
  if type(command) == 'string' then
    return function ()
      vim.cmd(command)
    end
  else
    return function ()
      return command(first_install)
    end
  end
end

P.install_missing_plugins = function (install_context)
  return function ()
    if not install_context.has_missing_plugins() then
      return
    end

    local fn = P.run_install_plugins(install_context, false)
    if fn then
      fn()
    end
  end
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

-- extension for auto-install plugin manager and missing plugins
X.auto_install = function (options)
  local opts = options or {}
  vim.validate {
    plug = { opts.plug, 'b', true },
    manager = { opts.manager, 'b', true },
    missing = { opts.missing, 'b', true },
    post_install_delay = { opts.post_install_delay, 'n', true }
  }
  opts = vim.tbl_extend('keep', opts, {
    plug = true,
    manager = true,
    missing = true,
    post_install_delay = 100
  })

  local function installation(install_context)
    return function (ctx)
      ctx.is_installed = P.backend.is_installed and P.backend.is_installed()

      if ctx.is_installed then
        -- already installed, do nothing
        return
      end

      -- attempt to install plugin manager automatically,
      local install_status = (
        (opts.manager or opts.plug) and
        P.backend.install and P.backend.install()
      )

      if install_status then
        -- install plugins for first installation
        if install_context then
          P.auto('VimEnter', P.run_install_plugins(install_context, true))
        end
      else
        -- installation skipped or failed
        vim.notify(string.format(
          '[%s] Unable to automatically install backend \'%s\'',
          'plug.nvim',
          P.backend.name
        ), vim.log.levels.ERROR)
        return false
      end
    end
  end

  local function post_installation(dispatch, install_context)
    return function (ctx)
      if install_context and install_context.has_missing_plugins then
        P.auto(
          'VimEnter',
          P.install_missing_plugins(install_context)
        )
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
                plugin.id,
                ctx.stderr
              ), vim.log.levels.ERROR)
            end
            if ctx.stdout then
              vim.notify(string.format(
                '[%s] Plugin "%s" has an output during post installation:\n%s',
                'plug.nvim',
                plugin.id,
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
    entry = function (hook, dispatch, ctx)
      local install_context

      if opts.missing then
        install_context = ctx
      end
      hook('setup', installation(install_context))

      if install_context and ctx.backend == 'vim-plug' then
        hook('plugin_options', inject_post_setup)
      end

      hook('done', post_installation(dispatch, install_context))
    end
  }
end

-- extension for per-plugin configurations
X.config = setmetatable({
  configs = {}
}, {
  __index = function (self, name)
    local fn = rawget(self, 'configs')[name]
    return function ()
      if fn then
        return fn()
      end
    end
  end,
  __call = function (self)
    local function configure_plugin(ctx, plugin)
      if type(plugin.config) ~= 'function' then
        return
      end

      plugin.config()
    end

    local function handle_to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('config', 'conf')
        if type(plugin.config) ~= 'function' then
          return
        end

        local configs = rawget(self, 'configs')
        configs[plugin.id] = plugin.config
        options['conf'] = plugin.id
      end
    end

    return function (hook, ctx)
      if ctx.backend == 'vim-plug' then
        hook('plugin_post', configure_plugin)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', handle_to_options(ctx))
      elseif ctx.backend == 'lazy.nvim' or ctx.backend == 'pckr.nvim' then
        hook('plugin_options', P.proxy_to_options('config'))
      end
    end
  end
})

-- extension for per-plugin deferred configurations
X.defer = setmetatable({
  defers = {},
  delays = {},
  delay_duration = 0
}, {
  __index = function (self, name)
    return function (kind)
      local fn = rawget(self, kind .. 's')[name]
      if fn then
        if kind == 'defer' then
          vim.defer_fn(fn, 0)
        else
          vim.defer_fn(fn, rawget(self, 'delay_duration'))
        end
      end
    end
  end,
  __call = function (self, options)
    local opts = options or {}
    vim.validate {
      defer_delay = { opts.defer_delay, 'n', true }
    }

    rawset(self, 'delay_duration', opts.defer_delay or P.delay_post)

    local function defer_plugin(ctx, plugin)
      if type(plugin.defer) == 'function' then
        vim.defer_fn(plugin.defer, 0)
      end

      if type(plugin.delay) == 'function' then
        vim.defer_fn(plugin.delay, rawget(self, 'delay_duration'))
      end
    end

    local function to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('defer', 'defer')
        ctx.setup_handler('defer', 'delay')

        if type(plugin.defer) == 'function' then
          local defers = rawget(self, 'defers')
          defers[plugin.id] = plugin.defer
          options['defer'] = plugin.id
        end

        if type(plugin.delay) == 'function' then
          local delays = rawget(self, 'delays')
          delays[plugin.id] = plugin.delay
          options['delay'] = plugin.id
        end
      end
    end

    return function (hook, ctx)
      if
        ctx.backend == 'vim-plug' or
        ctx.backend == 'lazy.nvim' or
        ctx.backend == 'pckr.nvim'
      then
        hook('plugin_post', defer_plugin)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', to_options(ctx))
      end
    end
  end
})

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

-- extension for proxy plugin configurations to plugin manager's options
X.proxy = function (opts)
  local notify = false
  local function proxy(map)
    return function (_, options, _, plugin)
      for from_key, to in pairs(map) do
        local from = from_key

        if type(from) ~= 'string' then
          from = to
        end

        if
          type(to) == 'string' or
          (type(to) == 'function' and type(from) == 'string')
        then
          P.proxy_key(plugin, options, from, to)
        elseif not notify then
          notify = true
          local from_type = 'One of the key in proxy mappings'

          if type(from) == 'string' then
            from_type = string.format('Proxy mappings for \'%s\'', from)
          end

          vim.notify(string.format(
            '[%s] %s has a value of type \'%s\' instead of \'string\'',
            'plug.nvim',
            from_type,
            type(to)
          ), vim.log.levels.ERROR)
        end
      end
    end
  end

  return function (hook, ctx)
    local map = opts or {}

    if type(opts) == 'function' then
      map = map(ctx.backend)
    end

    if type(map) ~= 'table' then
      vim.notify(string.format(
        '[%s] Proxy mappings has a type \'%s\' instead of \'table\'',
        'plug.nvim',
        type(map)
      ), vim.log.levels.ERROR)
      return
    end

    hook('plugin_options', proxy(map))
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

  local function require_plugins(_, plugin, install_plugin)
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

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' then
      hook('plugin', require_plugins)
    elseif ctx.backend == 'packer.nvim' or ctx.backend == 'pckr.nvim' then
      hook('plugin_options', P.proxy_to_options('requires'))
    elseif ctx.backend == 'lazy.nvim' then
      hook('plugin_options', P.proxy_to_options('requires', 'dependencies'))
    end
  end
end

-- extension for supporting pre-loading setup
X.setup = setmetatable({
  setups = {}
}, {
  __index = function (self, name)
    local fn = rawget(self, 'setups')[name]
    return function()
      if fn then
        return fn()
      end
    end
  end,
  __call = function (self)
    local function setup()
      P.for_each(
        function (plugin)
          if type(plugin.setup) == 'function' then
            plugin.setup()
          end
        end
      )
    end

    local function handle_to_options(ctx)
      return function(_, options, _, plugin)
        ctx.setup_handler('setup', 'preconfigure', 'setup')
        if type(plugin.setup) ~= 'function' then
          return
        end

        local setups = rawget(self, 'setups')
        setups[plugin.id] = plugin.setup
        options['preconfigure'] = plugin.id
      end
    end

    return function (hook, ctx)
      if ctx.backend == 'vim-plug' then
        hook('pre_setup', setup)
      elseif ctx.backend == 'packer.nvim' then
        hook('plugin_options', handle_to_options(ctx))
      elseif ctx.backend == 'lazy.nvim' then
        hook('plugin_options', P.proxy_to_options('setup', 'init'))
      elseif ctx.backend == 'pckr.nvim' then
        hook('plugin_options', P.proxy_to_options('setup', 'config_pre'))
      end
    end
  end
})

-- extension for supporting pre-loading setup
X.skip = function ()
  local function skip_plugin(_, plugin)
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

  local function proxy_to_options(name, match)
    return function (_, options, _, plugin)
      if plugin.skip == nil then
        return
      end

      options[name] = skip_plugin(_, plugin) == match
    end
  end

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' or ctx.backend == 'pckr.nvim' then
      hook('plugin', skip_plugin)
    elseif ctx.backend == 'packer.nvim' then
      hook('plugin_options', proxy_to_options('disable', false))
    elseif ctx.backend == 'lazy.nvim' then
      hook('plugin_options', proxy_to_options('enabled'))
    end
  end
end

M.extension = X
M.backend = B

return setmetatable(M, {
  __call = function (_, ...)
    return M.install(...)
  end
})
