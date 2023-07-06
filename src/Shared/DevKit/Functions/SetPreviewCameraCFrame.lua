--[=[
    This function generates a cframe that is meant to generate a cframe for preview
    cameras that were they have to be flush with the object they are prevewing.
    
    i.e the camera position of a minimap.  

    Note: Set the Camera FOV property to 1.
]=]
--# This function is essential for the map preview Viewport Frame camera. it's what
--# automatically updates the camera position based on the map size. Thanks you so much for this Sona <3
local function SetPreviewCameraCFrame(width: number, FOV: number, axis: Vector3): CFrame
	width = 0.5 * (width or 1)
	FOV = 0.5 * (FOV or 1)

	local Height = width / math.tan(math.rad(FOV))
	return CFrame.lookAt(axis * Height, Vector3.zero)
end

return SetPreviewCameraCFrame
