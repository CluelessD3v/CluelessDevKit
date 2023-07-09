local function GetDictionaryLenght(t)
	local c = 0
	for _, _ in t do
		c += 1
	end

	return c
end

return GetDictionaryLenght
