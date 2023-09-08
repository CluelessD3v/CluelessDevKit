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
    
    - _meta_data_   
    - _On_Removed_ 
    - _On_Inserted_
    - _len_
    - _actual_table_
    
    
    Warning: a wrapped table is Incompatible with luau's table library DO NOT cross use them!
    the internal metadata of the table will be lost/go out of date (which means this has to be expanded.)
--]]

local function nop() end

local cupboard = {}

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
	local actualTable = rawget(t, "_actual_table_")
	return actualTable[k]
end

proxyHandler.__newindex = function(t, k, v)
	local actualTable = rawget(t, "_actual_table_")
	local metadata = rawget(t, "_meta_data_")

	-- order matters, gotta catch callbacks first else they'll get
	-- indexed to actualTable.
	if k == "_On_Removed_" or k == "_On_Inserted_" and type(v) == "function" then
		assert(type(v) == "function", "Unable to assign callback " .. k .. " function expected got " .. typeof(v))
		metadata[k] = v
		return
	end
	if actualTable[k] ~= nil and v == nil then
		local oldVal = actualTable[k]
		actualTable[k] = nil
		metadata._len_ -= 1
		metadata._On_Removed_(t, k, oldVal)
		return
	end

	if actualTable[k] == nil then
		actualTable[k] = v
		metadata._len_ += 1
		metadata._On_Inserted_(t, k, v)
		return
	end

	-- Not incrementing _len_ here cause it's a replacement case
	-- no "true" insertion occured
	if actualTable[k] ~= nil and actualTable[k] ~= v then
		actualTable[k] = v
		metadata._On_Replaced_(t, k, v)
		return
	end
end

proxyHandler.__tostring = function(t)
	local actualTable = rawget(t, "_actual_table_")
	print(actualTable)
	return ""
end

proxyHandler.__iter = function(t)
	local actualTable = rawget(t, "_actual_table_")
	return next, actualTable
end

proxyHandler.__len = function(t)
	local metadata = rawget(t, "_meta_data_")
	return metadata._len_
end

cupboard.wrap = function(
	t: { [any]: any },
	shouldFire: boolean,
	callbacks
): {
	_OnRemoved_: (t, k, v) -> nil,
	_OnInserted_: (t, k, v) -> nil,
}
	assert(type(t) == "table", "bad argument t, it must be of type table!")
	assert(type(shouldFire) == "boolean", "bad argument shouldFire, it must be of type boolean!")
	assert(
		type(callbacks) == "table" or type(callbacks) == "nil",
		"bad argument onInserted, it must be of type table or nil!"
	)

	callbacks = callbacks or {}
	assert(
		type(callbacks.OnInserted) == "function" or type(callbacks.OnInserted) == "nil",
		"bad argument onInserted, it must be of type function!"
	)

	assert(
		type(callbacks.OnRemoved) == "function" or type(callbacks.OnRemoved) == "nil",
		"bad argument OnRemoved, it must be of type function!"
	)

	assert(
		type(callbacks.OnReplaced) == "function" or type(callbacks.OnReplaced) == "nil",
		"bad argument OnReplaced, it must be of type function!"
	)

	-- important to not put the metadata table inside actualTable...
	-- else it would be counted as an element of it!
	local proxy = {
		_actual_table_ = {},

		_meta_data_ = {
			_On_Removed_ = callbacks.OnRemoved or nop,
			_On_Inserted_ = callbacks.OnInserted or nop,
			_On_Replaced_ = callbacks.OnReplaced or nop,
			_len_ = 0, --> optimization to track the lenght of the table, else inserting be borderline un-useable
		},
	}
	setmetatable(proxy, proxyHandler)

	-- if it should call OnInserted callback or not when
	-- inserting the contents of t. the callback it's called
	-- through the proxy btw.
	if shouldFire then
		for k, v in t do
			proxy[k] = v
		end
	else
		for k, v in t do
			proxy._meta_data_._len_ += 1
			rawset(proxy._actual_table_, k, v)
		end
	end

	return proxy
end

cupboard.insert = function(t: { [any]: any }, v: any, pos: number?)
	assert(type(t) == "table", "bad argument t, it must be of type table!")
	assert(type(pos) == "number" or type(pos) == "nil", "bad argument pos, it must be of type number or nil!")

	if pos then
		-- Get the "true" table so we can bypass the metamethod calls, not doing
		-- it would cause _on_inserted_ to be called every time a value is shifted
		local actualTable = rawget(t, "_actual_table_")
		local metadata = rawget(t, "_meta_data_")

		-- right shift vals
		for i = metadata._len_, pos, -1 do
			actualTable[i + 1] = actualTable[i]
		end

		-- index the new value in the desired position using the given
		-- table so _on_inserted_ is called.
		t[pos] = v
		metadata._len_ += 1
	else
		t[#t + 1] = v
	end
end

cupboard.remove = function(t, pos: any)
	assert(type(t) == "table", "bad argument t, it must be of type table!")
	assert(type(pos) == "number", "bad argument key, it must be of type number!")
	local actualTable = rawget(t, "_actual_table_")
	local metadata = rawget(t, "_meta_data_")
	local len = metadata._len_

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
	local actualTable = rawget(t, "_actual_table_")
	local metadata = rawget(t, "_meta_data_")
	init = init or 1
	print(actualTable)
	for i = init, metadata._len_ do
		if actualTable[i] == v then
			return i
		end
	end

	return nil
end

cupboard.unwrap = function(t)
	local actualTable = rawget(t, "_actual_table_")
	setmetatable(t, nil)
	t = nil
	return actualTable
end

return cupboard
