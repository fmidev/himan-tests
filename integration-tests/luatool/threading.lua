-- Synthetic test for luatool with multiple threads

local t = luatool:Fetch(current_time, level(HPLevelType.kHeight, 0), param("T-K"), current_forecast_type)

if not t then
  return
end

local res = {}

for i=1, #t do
  local _t = t[i]

  res[i] = _t + 10

end

result:SetValues(res)
result:SetParam(param("T-K"))
luatool:WriteToFile(result)

