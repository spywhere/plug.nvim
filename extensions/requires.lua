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

  local function proxy_to_options(name)
    return function (_, options, _, plugin)
      if not plugin.requires then
        return
      end

      options[name] = plugin.requires
    end
  end

  return function (hook, ctx)
    if ctx.backend == 'vim-plug' then
      hook('plugin', require_plugins)
    elseif ctx.backend == 'packer.nvim' or ctx.backend == 'pckr.nvim' then
      hook('plugin_options', proxy_to_options('requires'))
    elseif ctx.backend == 'lazy.nvim' then
      hook('plugin_options', proxy_to_options('dependencies'))
    end
  end
end
