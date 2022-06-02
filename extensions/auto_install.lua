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
