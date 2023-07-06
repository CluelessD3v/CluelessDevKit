local Camera = workspace.CurrentCamera
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

local RaycastFromMouse = {}

RaycastFromMouse.FromViewportPoint = function(distance, raycastParams): RaycastResult
	local unitRay: Ray = Camera:ViewportPointToRay(Mouse.X, Mouse.Y)
	local rayCastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * distance, raycastParams)
	return rayCastResult
end

RaycastFromMouse.FromScreenPoint = function(distance, raycastParams): RaycastResult
	local unitRay: Ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
	local rayCastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * distance, raycastParams)
	return rayCastResult
end

return RaycastFromMouse
