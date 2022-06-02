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
