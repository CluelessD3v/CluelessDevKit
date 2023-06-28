-- stylua: ignore start

local warnMsg =
	"No signal dependency detected, The module will not be useable until its signal dependency is set: ClampedNumer.Signal = YourSignalLibrary"

-- !== ================================================================================||>
-- !== Proxy
-- !== ================================================================================||>

local proxy = {}
proxy.__index = function(t: {_store: ClampedNumber}, key)
	local self = rawget(t, "_store")
	return self[key]
end

proxy.__newindex = function(t: {_store: ClampedNumber}, key, value: number)
	local self: ClampedNumber = t._store
	
	if key == "Value" then
		self[key] = math.clamp(value, self.Min, self.Max)
		self.Changed:Fire(self.Value)
		
		if self.Value >= self.Max then
			self.MaxReached:Fire()
		elseif self.Value <= self.Min then
			self.MinReached:Fire()
		end
	
	--[[
		Prevents Min and Max from ever surpassing each other, cause yah! Min should
		not ever be bigger than max, and vice versa! 
	]]
	elseif key == "Min" then
		if value < self.Max then
			self.Min = value
		end
	
	elseif key == "Max" then
		if value > self.Min then
			self.Max = value
		end
	end
end

--//XXX EHHHH not sure how I feel about this.
proxy.__tostring = function(t)
	local self: ClampedNumber = rawget(t, "_store")
	local msg = "Value: " .. self.Value .. " | Min: " .. self.Min .. " | Max: " .. self.Max
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


export type ClampedNumber = {
	Value: number,
	Max: number,
	Min: number,
	Changed: Signal<number>,
	MinReached: Signal<any>,
	MaxReached: Signal<any>,
}


local ClampedNumber = {}
ClampedNumber.Signal = nil

ClampedNumber.new = function(initialValue: number, minValue: number, maxValue: number): ClampedNumber 
	--//TODO make a case to check that the arguments were passed
	--//TODO make a case to check that the arguments are of the correct type
	if not ClampedNumber.Signal then
		warn(warnMsg)
	end


	local self = {}
	self.Min        = math.min(minValue, maxValue) 
	self.Max        = math.max(minValue, maxValue)
	self.Value      = math.clamp(initialValue, self.Min, self.Max)
	self.Changed    = ClampedNumber.Signal.new()
	self.MinReached = ClampedNumber.Signal.new()
	self.MaxReached = ClampedNumber.Signal.new()

	return setmetatable({ _store = self }, proxy)
end

return ClampedNumber
-- stylua: ignore end
