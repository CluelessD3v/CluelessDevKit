--!strict
local ReplicatedStorage = game.ReplicatedStorage
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.signal)

local Observable = require(ReplicatedStorage.DevKit.Classes.Observable)
Observable.Signal = Signal
local o = Observable.new("hi")
o.Changed:Connect(function(newValue)
	print(newValue)
end)

local cn = require(ReplicatedStorage.DevKit.Classes.ClampedNumber)
cn.Signal = Signal
local newCN = cn.new(5, 1, 10)
newCN.Value = 15
newCN.Min = 5
newCN.Max = 10

o.Value = 25
print(o.Value)

newCN.MinReached:Connect(function()
	print("min reached")
end)

newCN.MaxReached:Connect(function()
	print("max reached")
end)

newCN.Changed:Connect(function(newValue)
	print(newValue)
end)

for i = newCN.Min, newCN.Max do
	newCN.Value = i
end
