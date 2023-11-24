i.uuid = function ()
  local template = 'xxxx-yyyy-xxxx-yyyy'
  return string.gsub(template, '[xy]', function (c)
    return string.format(
      '%x',
      c == 'x' and math.random(0, 0xf) or math.random(8, 0xb)
    )
  end)
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
