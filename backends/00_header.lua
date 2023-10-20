B = i.soft_table(function (k) -- backends
  return function ()
    return {
      name = k
    }
  end
end)
