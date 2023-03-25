local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.signal)
local Trove  = require(Packages.trove)

local Utilities = ReplicatedStorage.Utilities
local TableToString = require(Utilities:FindFirstChild("TableToString", true))

if not TableToString then
     TableToString = function(...)
          return ...
     end
end

type ClampedNumber = {
     Value           : number,
     Min             : number,
     Max             : number,
     Changed         : typeof(Signal.new()),
     PropertyChanged : typeof(Signal.new()),
     MaxReached      : typeof(Signal.new()),
     MibReached      : typeof(Signal.new()),
}


local ClampedNumber = {} 
ClampedNumber.__index = ClampedNumber


local Troves = {}

function ClampedNumber.new(initialValue, min, max): ClampedNumber
     local self = setmetatable({}, ClampedNumber)
     local myTrove = Trove.new()

     self.Properties = {}
     self.Properties.Min   = math.min(min, max)
     self.Properties.Max   = math.max(min, max)
     self.Properties.Value = math.clamp(initialValue, self.Properties.Min, self.Properties.Max)


     self.Signals                 = {}
     self.Signals.Changed         = myTrove:Add(Signal.new())
     self.Signals.PropertyChanged = myTrove:Add(Signal.new())
     self.Signals.MaxReached      = myTrove:Add(Signal.new())
     self.Signals.MinReached      = myTrove:Add(Signal.new())
     


     local proxy = setmetatable({}, {
          __index = function(_, k)
               return self.Properties[k] or self.Signals[k]
          end,

          __newindex = function(_, k, v)
               if k == "Value" then
                    local myMin = self.Properties.Min
                    local myMax = self.Properties.Max
                    
                    self.Properties.Value = math.clamp(v, myMin, myMax)
                    
                    self.Signals.Changed:Fire(v)
                    self.Signals.PropertyChanged:Fire(k, v)

                    if v == myMax then
                         self.Signals.MaxReached:Fire()
                    end  

                    if v == myMin then
                         self.Signals.MinReached:Fire()
                    end
               else
                    self.Properties[k] = v
                    self.Signals.PropertyChanged:Fire(k, v)
               end
          end,

          __tostring = function()
               return TableToString(self)
          end,
     })

     Troves[proxy] = myTrove
     return proxy :: ClampedNumber
end


function ClampedNumber:Destroy()
     Troves[self]:Destroy()
end


return ClampedNumber



