current_time:GetValidDateTime():Adjust(HPTimeResolution.kHourResolution, -3)
local prev_t = luatool:FetchWithType(current_time, current_level, param("T-K"), current_forecast_type)

current_time:GetValidDateTime():Adjust(HPTimeResolution.kHourResolution, 6)
local next_t = luatool:FetchWithType(current_time, current_level, param("T-K"), current_forecast_type)

local res = {}

for i=1, #prev_t do
  res[i] = (prev_t[i] + next_t[i]) / 2
end

result:SetValues(res)

local agg = aggregation(HPAggregationType.kAverage, time_duration(HPTimeResolution.kHourResolution, 6), time_duration(HPTimeResolution.kHourResolution, -3))
local par = param("T-MEAN-K")

par:SetAggregation(agg)

result:SetParam(par)
luatool:WriteToFile(result)
