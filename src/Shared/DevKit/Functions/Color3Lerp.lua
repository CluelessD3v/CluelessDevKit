--[[
    Small Color lerping libary, all credit to Alan Zucconi, this code was ripped straight
    from his blogpost here https://www.alanzucconi.com/2016/01/06/colour-interpolation/

    Note that this is an extremely simple color lerp doesn't yield good results, 
    use it only if you need a quick gradient, else this plug-in can actual number
    Sequences to make HCL gradients: https://devforum.roblox.com/t/cse-the-ultimate-gradient-editor/2171637
]]

local LerpRGB = function(a: Color3, b: Color3, t: number)
	local R = a.R + (b.R - a.R) * t
	local G = a.G + (b.G - a.G) * t
	local B = a.B + (b.B - a.B) * t

	return Color3.new(R, G, B)
end

return LerpRGB
