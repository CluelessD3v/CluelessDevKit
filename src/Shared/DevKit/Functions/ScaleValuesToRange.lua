--[=[
	This is a more nuanced form of value normalization that allows me to map and 
	normalize values to a desired scale range, ensuring they stay within the 
	specified bounds.

	i.e let's say I want to convert player health from a [0, 100] range to a 
	[0, 1] range!

	given a current health of 25 this function wold return

 	ScaleValueToRange(25, 0, 100, 0, 1) --> 0.25
]=]

local function ScaleValueToRange(x: number, min: number, max: number, minScale, maxScale: number): number
	x = (x - min) / (max - min) * maxScale
	return math.clamp(x, minScale, maxScale)
end

return ScaleValueToRange
