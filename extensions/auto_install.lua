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
