--[[
    "Reactive" luau table that allows for callbacks to be invoked on Inserted/Removed, the reasoning behind this is to facilitate 
    the implementation of existential processing as described in the Data Oriented Design Book https://www.dataorienteddesign.com/dodbook/node4.html
    
    Given that in theory it would allow devs to call functions/fire events on the table being inserted removed w/o 
    having to make whole function libraries or managers.
    
    
    Important Notes
    - Supports the # operator for both mixed and non mixed tables
    - Can be iterated, but!
    - DOES NOT support ipairs() or pairs(), only the generic iterator.
    - Even with the attempted optimizations, the library functions can be
      up to 10x slower than luau's table library... directly index when 
      possible!: yourTable[k] = v
      
    Reserved names/keys:
    these are names YOU CAN'T index to your wrapped table, they've been _full_snake_cased_
    to minimize chances of the dev having name collisions however... If you're 
    casing your keys/variables like that on a regular basis, seek jesus :v
    
    - __metadata   
    - __onRemoved 
    - __onInserted
	- __onInserted
    - __size
    - __actualTable
    
    
    Warning: a wrapped table is Incompatible with luau's table library DO NOT cross use them!
    the internal metadata of the table will be lost/go out of date (which means this has to be expanded.)
--]]

local function nop() end

local cupboard = {}

-- !== ================================================================================||>
-- !== Proxy
-- !== ================================================================================||>
--[[
	the proxyHandler is the star of the show, it's a metatable that allows me to
	detect insertions/removals from a given wrapped table through the proxy pattern
	https://www.lua.org/pil/13.4.4.html

	TL;DR: __newindex won't be called if the given key already exists in the table,
	so setting a metatable to a table to track accesses is NOT ENOUGH.
	
	but we can loophole this by using an empty table as a proxy so __newindex ALWAYS
	fires which indeed allows me to detect table accesses and do all the handling
	required for this usecase, allowing me to make a table reactive.

	in this case the proxy wraps the given table, hence why the constructor is 
	named wrap.
]]
local proxyHandler = {}

proxyHandler.__index = function(t, k)
	local actualTable = rawget(t, "__actualTable")
	return actualTable[k]
end

proxyHandler.__newindex = function(t, k, v)
	local actualTable = rawget(t, "__actualTable")
	local metadata = rawget(t, "__metadata")

	-- order matters, gotta catch callbacks first else they'll get
	-- indexed to actualTable.
	if k == "__onRemoved" or k == "__onInserted" or k == "__onReplaced" and type(v) == "function" then
		assert(type(v) == "function", "Unable to assign callback " .. k .. " function expected got " .. typeof(v))
		metadata[k] = v
		return
	end
	if actualTable[k] ~= nil and v == nil then
		local oldVal = actualTable[k]
		actualTable[k] = nil
		metadata.__size -= 1
		metadata.__onRemoved(t, k, oldVal)
		return
	end

	if actualTable[k] == nil then
		actualTable[k] = v
		metadata.__size += 1
		metadata.__onInserted(t, k, v)
		return
	end

	-- Not incrementing __size here cause it's a replacement case
	-- no "true" insertion occured
	if actualTable[k] ~= nil and actualTable[k] ~= v then
		actualTable[k] = v
		metadata.__onReplaced(t, k, v)
		return
	end
end

proxyHandler.__tostring = function(t)
	local actualTable = rawget(t, "__actualTable")
	print(actualTable)
	return ""
end

proxyHandler.__iter = function(t)
	local actualTable = rawget(t, "__actualTable")
	return next, actualTable
end

proxyHandler.__len = function(t)
	local metadata = rawget(t, "__metadata")
	return metadata.__size
end

-- !== ================================================================================||>
-- !== Library
-- !== ================================================================================||>
cupboard.wrap = function(
	t: { [any]: any },
	shouldCallOnInserted: boolean, -- calls onInserted for each item in the given table
	callbacks
): {
	__onRemoved: (t: { [any]: any }, k: any, v: any) -> nil,
	__onInserted: (t: { [any]: any }, k: any, v: any) -> nil,
	__onReplaced: (t: { [any]: any }, k: any, v: any) -> nil,
}
	-- Assertion pass to verify types.

	assert(type(t) == "table", "bad argument t, it must be of type table!")
	assert(type(shouldCallOnInserted) == "boolean", "bad argument shouldFire, it must be of type boolean!")
	assert(
		type(callbacks) == "table" or type(callbacks) == "nil",
		"bad argument onInserted, it must be of type table or nil!"
	)

	callbacks = callbacks or {}

	assert(
		type(callbacks.onInserted) == "function" or type(callbacks.onInserted) == "nil",
		"bad argument onInserted, it must be of type function!"
	)

	assert(
		type(callbacks.onRemoved) == "function" or type(callbacks.onRemoved) == "nil",
		"bad argument OnRemoved, it must be of type function!"
	)

	assert(
		type(callbacks.onReplaced) == "function" or type(callbacks.OnReplaced) == "nil",
		"bad argument OnReplaced, it must be of type function!"
	)

	-- stash all of the given t key value pairs in another table and delete them
	-- from t, this is because t will now become an empty proxy for the metamethods
	-- to fire on it, and easily allows to wrap an already existing table
	local actualTable = {}
	local initialTableSize = 0

	for k, v in t do
		actualTable[k] = v
		initialTableSize += 1
		t[k] = nil
	end

	-- make t a proxy and initialize the its metadata
	t.__actualTable = actualTable
	t.__metadata = { --> metadata's not inside actualTable so it's not counted as a value of it
		__onRemoved = callbacks.onRemoved or nop,
		__onInserted = callbacks.onInserted or nop,
		__onReplaced = callbacks.onReplaced or nop,
		__size = initialTableSize, --> optimization to track the size of the table, else inserting would be borderline un-useable
	}

	setmetatable(t, proxyHandler)

	-- this is done at this step for safety so any key, value from t can be
	-- safely reached in the callback w/o it being nil cause it was not inserted
	-- yet
	if shouldCallOnInserted == true and callbacks.onInserted then
		for k, v in actualTable do
			callbacks.onInserted(t, k, v)
		end
	end

	return t
end

cupboard.insert = function(t: { [any]: any }, v: any, pos: number?)
	assert(type(t) == "table", "bad argument t, it must be of type table!")
	assert(type(pos) == "number" or type(pos) == "nil", "bad argument pos, it must be of type number or nil!")

	if pos then
		-- Get the "true" table so we can bypass the metamethod calls, not doing
		-- it would cause _on_inserted_ to be called every time a value is shifted
		local actualTable = rawget(t, "__actualTable")
		local metadata = rawget(t, "__metadata")

		-- right shift vals
		for i = metadata.__size, pos, -1 do
			actualTable[i + 1] = actualTable[i]
		end

		-- index the new value in the desired position using the given
		-- table so _on_inserted_ is called.
		t[pos] = v
		metadata.__size += 1
	else
		t[#t + 1] = v
	end
end

cupboard.remove = function(t, pos: any)
	assert(type(t) == "table", "bad argument t, it must be of type table!")
	assert(type(pos) == "number", "bad argument key, it must be of type number!")
	local actualTable = rawget(t, "__actualTable")
	local metadata = rawget(t, "__metadata")
	local len = metadata.__size

	-- t[k] = nil leaves a gap in the table, which would break array functionality
	-- so the values gotta be left shifted to fill the gap, also do this on the
	-- given table so _on_removed_ is called.
	t[pos] = nil

	-- left shift vals
	for i = pos, len, 1 do
		actualTable[i] = actualTable[i + 1]
	end
end

cupboard.find = function(t, v, init: number?)
	local actualTable = rawget(t, "__actualTable")
	local metadata = rawget(t, "__metadata")
	init = init or 1
	for i = init, metadata.__size do
		if actualTable[i] == v then
			return i
		end
	end

	return nil
end

cupboard.unwrap = function(t)
	local actualTable = rawget(t, "__actualTable")
	setmetatable(t, nil)
	t = nil
	return actualTable
end

return cupboard
