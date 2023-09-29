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
        P.print(
          'plug.nvim: Unable to automatically install backend \'%s\'',
          P.backend.name
        )
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
