local module = {}

local function getLenght(t)
	local c = 0
	for _ in t do
		c += 1
	end
	return c
end

-- !== ================================================================================||>
-- !== Array operations
-- !== ================================================================================||>
module.Array = {}

module.Array.Union = function(a, b)
	local lookUp = {}
	for _, v in a do
		lookUp[v] = true
	end

	for _, v in b do
		lookUp[v] = true
	end

	local union = table.create(getLenght(lookUp))

	for _, v in union do
		table.insert(union, v)
	end

	return union
end

module.Array.Intersect = function(a, b)
	local intersection = {}
	for _, v in a do
		if table.find(v, b) then
			table.insert(intersection, v)
		end
	end

	return intersection
end

module.Array.Difference = function(a, b)
	local difference = {}
	for _, v in a do
		if table.find(v, b) then
			continue
		end

		table.insert(difference, v)
	end

	return difference
end

-- !== ================================================================================||>
-- !== Dictionary operations
-- !== ================================================================================||>
module.Dictionary = {}

module.Dictionary.Union = function(a, b)
	local union = {}

	for v in a do
		union[v] = true
	end

	for v in b do
		union[v] = true
	end

	return union
end

module.Dictionary.Intersect = function(a, b)
	local intersection = {}
	for v in a do
		if b[v] then
			intersection[v] = true
		end
	end

	return intersection
end

module.Dictionary.Difference = function(a, b)
	local difference = {}
	for v in a do
		if b[v] then
			continue
		end

		difference[v] = true
	end

	return difference
end

return module
