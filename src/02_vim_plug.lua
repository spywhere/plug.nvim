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
