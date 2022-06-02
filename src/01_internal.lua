i.increment = (function ()
  local i = 0
  return function ()
    i = i + 1
    return i
  end
end)()

i.wrap = function (value)
  if type(value) == 'table' then
    return value
  else
    return { value }
  end
end

i.recurse = function (fn)
  return (function (next) return next(next) end)(fn)
end

i.generator = function (fn, default)
  return i.recurse(function (next)
    return function (value)
      return fn(next(next), value)
    end
  end)(default)
end
