local function V3ToV3i16(v: Vector3)
	if typeof(v) ~= "Vector3" then
		error(v .. " is not a vector")
	end

	return Vector3int16.new(v.X, v.Y, v.Z)
end

return Vector3int16
