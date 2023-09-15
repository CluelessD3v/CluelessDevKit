--stylua: ignore start
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local RaycastFromMouse = {}

RaycastFromMouse.FromViewportPoint = function(distance: number, raycastParams): (RaycastResult, Ray)
	local mousePos      = UserInputService:GetMouseLocation()
	local unitRay: Ray  = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local rayCastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * distance, raycastParams)
	return rayCastResult, unitRay
end

-- screenPointToRay accounts for the guiInset so the positions it returns will
-- always be 32 pixels lower than where your mouse actually is

RaycastFromMouse.FromScreenPoint = function(distance: number, raycastParams): (RaycastResult, Ray)
	local mousePos      = UserInputService:GetMouseLocation()
	local unitRay: Ray  = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
	local rayCastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * distance, raycastParams)
	return rayCastResult, unitRay
end

return RaycastFromMouse
--stylua: ignore end
