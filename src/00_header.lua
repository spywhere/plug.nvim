local config_home = vim.fn.stdpath('config')
local i = {} -- internal
local B = setmetatable({}, { -- backends
  __call = function (self, name, context)
    return (rawget(self, name) or rawget(self, 'vim-plug'))(context)
  end,
  __newindex = function (self, name, value)
    rawset(self, name, function (...)
      local backend = value(...)
      backend.name = name
      return backend
    end)
  end
})
local M = {} -- public
local X = {} -- extensions
local P = { -- private
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
