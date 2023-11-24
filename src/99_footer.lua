M.extension = X
M.backend = B

return setmetatable(M, {
  __call = function (_, ...)
    return M.install(...)
  end
})
