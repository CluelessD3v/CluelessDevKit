--[=[
	This is a more nuanced form of value normalization that allows me to map 
	values to a desired scale range, ensuring they stay within the 	specified 
	bounds.

	i.e let's say I want to convert player health from a [0, 100] range to a 
	[0, 1] range!

	given a current health of 25 this function wold return

 	Remap(25, 0, 100, 0, 1) --> 0.25
]=]

local function Remap(x: number, inputMin: number, inputMax: number, outputMin, outputMax: number): number
	x = (x - inputMin) / (inputMax - inputMin) * outputMax
	return math.clamp(x, outputMin, outputMax)
end

return Remap

