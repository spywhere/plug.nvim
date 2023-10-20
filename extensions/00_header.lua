X = i.soft_table(function (k) -- extensions
  P.print('Extension \'%s\' is not available', k)
  return function ()
  end
end)
