-- Total surface roughness for Hirlam
 
logger:Info("Calculating total surface roughness")

local sr = luatool:Fetch(current_time, current_level, param("SR-M"))
local srmom = luatool:Fetch(current_time, current_level, param("SRMOM-M"))

if not sr or not srmom then
    logger:Error("Data not found")
    return
end
 
local i = 0
local res = {}

for i=1, #sr do
	local _sr = sr[i]
	local _srmom = srmom[i]
	if _sr ~= kFloatMissing and _srmom ~= kFloatMissing then
		res[i] = _sr + _srmom
	end

end

result:SetValues(res)
result:SetParam(param("SR-M"))

luatool:WriteToFile(result)
