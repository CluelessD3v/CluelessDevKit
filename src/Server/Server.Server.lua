--!strict
local ReplicatedStorage = game.ReplicatedStorage
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.signal)

local wc = require(ReplicatedStorage.DevKit.Functions.WeightedChoice)

local weights = {
	a = 10,
	b = 20,
	c = 30,
	d = 40,
	e = 50,
}

for i = 1, 1E4 do
	print(wc(weights))
end
