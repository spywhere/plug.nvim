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

  local function to_options(_, options, _, plugin)
    if not plugin.requires then
      return
    end

    options.requires = plugin.requires
  end

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' then
      hook('plugin', require_plugins)
    elseif ctx.backend == 'packer.nvim' then
      hook('plugin_options', to_options)
    end
  end
end
