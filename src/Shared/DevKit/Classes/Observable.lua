-- stylua: ignore start

--[[
	Observable value utility for when you need to keep an eye on a value changing.
]]

local Signal = require(script.Parent.Parent.Signal)

-- !== ================================================================================||>
-- !== Proxy
-- !== ================================================================================||>
local proxy = {}
proxy.__index = function(t:  {_store: Observable}, key: string)
	local self = rawget(t, "_store")
	return self[key]
end

proxy.__newindex = function(t:  {_store: Observable}, key: string, value: any)
	local self: Observable = rawget(t, "_store")

    if key == "Value" then
        self.Value = value
        self.Changed:Fire(value)
    end
end

proxy.__tostring = function(t:  {_store: Observable})
	local self: Observable = rawget(t, "_store")
	local msg = "Value: " .. tostring(self.Value) 
	return msg
end

-- !== ================================================================================||>
-- !== Class
-- !== ================================================================================||>

-- Putting the signal types here allow the module to be used standalone while preserving type info
type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> nil?,
}


type Signal<U...> = {
	Connect: (self: Signal<U...>, handle:(U...) -> nil) -> Connection, 
	Once: (self: Signal<U...>, U...) -> Connection,
	DisconnectAll: (self: Signal<U...>) -> nil,
	Fire: (self: Signal<U...>, U...) -> nil,
	Wait: (self: Signal<U...>) -> U...,
}

export type Observable = {
    Value: any,
    Changed: Signal<any>
}


local Observable = {}

function Observable.new(initialValue: any): Observable

	local self = {}
	self.Value = initialValue
	self.Changed = Signal.new()
	return setmetatable({ _store = self }, proxy)
end



return Observable
-- stylua: ignore end
