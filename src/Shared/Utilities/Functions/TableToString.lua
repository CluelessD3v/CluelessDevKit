local function Table2String(tab, indent)
  local str = ""
  indent = indent or ""
  local alreadySeen = {}

  str = str .. "{\n"
  for k, v in pairs(tab) do
      local keyStr = tostring(k)
      local valStr = tostring(v)

      if type(v) == "table" then
          if alreadySeen[v] then
              valStr = "<cyclic reference>"
          else
              alreadySeen[v] = true
              valStr = Table2String(v, indent .. "   ")
          end
      end

      str = str .. indent .. "   [" .. keyStr .. "] = " .. valStr .. ",\n"
  end
  str = str .. indent .. "}"
  return str
end
  
  return Table2String