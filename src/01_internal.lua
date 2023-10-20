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

i.soft_table = function (fn)
  return setmetatable({}, {
    __index = function(self, k)
      local value = rawget(self, k)
      if not value then
        return fn(k)
      end
      return value
    end
  })
end
