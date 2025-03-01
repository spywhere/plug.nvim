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
