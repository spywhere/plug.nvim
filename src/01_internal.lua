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
