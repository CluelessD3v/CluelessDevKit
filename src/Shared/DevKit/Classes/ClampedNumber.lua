-- stylua: ignore start
--[=[
	Clamped number class for when you need to keep a number between a range and not
	litter your codebase with clamped values
]=]

local Signal = require(script.Parent.Parent.Signal)

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
		self.PropertyChanged:Fire(key, value)
		
		if self.Value >= self.Max then
			self.MaxReached:Fire()
		elseif self.Value <= self.Min then
			self.MinReached:Fire()
		end
	
		--# Prevents Min and Max from ever surpassing each other, cause yah! Min should
		--# not ever be bigger than max, and vice versa! 
	elseif key == "Min" then
		if value < self.Max then
			self.Min = value
			self.PropertyChanged:Fire(key, value)
		end
	
	elseif key == "Max" then
		if value > self.Min then
			self.Max = value
			self.PropertyChanged:Fire(key, value)
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
	Connect       : (self: Signal<U...>, handle:(U...) -> nil) -> Connection,
	Once          : (self: Signal<U...>, U...) -> Connection,
	DisconnectAll : (self: Signal<U...>) -> nil,
	Fire          : (self: Signal<U...>, U...) -> nil,
	Wait          : (self: Signal<U...>) -> U...,
}


export type ClampedNumber = {
	Value          : number,
	Max            : number,
	Min            : number,
	Changed        : Signal<number>,
	MinReached     : Signal<unknown>,
	MaxReached     : Signal<unknown>,
	PropertyChanged: Signal<unknown>
}


local ClampedNumber = {}
ClampedNumber.Signal = nil

ClampedNumber.new = function(initialValue: number, minValue: number, maxValue: number): ClampedNumber 
	--//TODO make a case to check that the arguments were passed
	--//TODO make a case to check that the arguments are of the correct type

	local self = {}
	-- Prevent min from being bigger than max and vice versa at creation by
	-- swapping them
	self.Min             = math.min(minValue, maxValue)
	self.Max             = math.max(minValue, maxValue)
	self.Value           = math.clamp(initialValue, self.Min, self.Max)
	self.Changed         = Signal.new()
	self.PropertyChanged = Signal.new()
	self.MinReached      = Signal.new()
	self.MaxReached      = Signal.new()

	return setmetatable({ _store = self }, proxy)
end

return ClampedNumber
-- stylua: ignore end
