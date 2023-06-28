local idCount = 0

local function GetSimpleID()
	idCount += 1
	return idCount
end

return GetSimpleID
