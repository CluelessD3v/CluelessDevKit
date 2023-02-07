local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.signal)
local Trove  = require(Packages.trove)

local Utilities = ReplicatedStorage.Utilities
local TableToString = require(Utilities.TableToString)

type ValueRange = {
     Value: number,
     Min: number,
     Max: number,
     Changed: typeof(Signal.new()),
     PropertyChanged: typeof(Signal.new()),  
}


local ValueRange = {} 
ValueRange.__index = ValueRange


local Troves = {}

function ValueRange.new(initialValue, min, max): ValueRange
     local self = setmetatable({}, ValueRange)
     local myTrove = Trove.new()

     self.Properties = {}
     self.Properties.Min   = math.min(min, max)
     self.Properties.Max   = math.max(min, max)
     self.Properties.Value = math.clamp(initialValue, self.Properties.Min, self.Properties.Max)


     self.Signals = {}
     self.Signals.Changed         = myTrove:Add(Signal.new())
     self.Signals.PropertyChanged = myTrove:Add(Signal.new())

     local proxy = setmetatable({}, {
          __index = function(_, k)
               return self.Properties[k] or self.Signals[k]
          end,

          __newindex = function(_, k, v)
               if k == "Value" then
                    self.Properties.Value = v
                    self.Signals.Changed:Fire(v)
                    self.Signals.PropertyChanged:Fire(k, v)

               elseif self.Properties[k]  then
                    self.Properties[k] = v
                    self.Signals.PropertyChanged:Fire(k, v)
               end
          end,

          __tostring = function()
               return TableToString(self)
          end

     })

     Troves[proxy] = myTrove
     return proxy :: ValueRange
end


function ValueRange:Destroy()
     Troves[self]:Destroy()
end


return ValueRange