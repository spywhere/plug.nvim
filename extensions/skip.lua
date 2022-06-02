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
