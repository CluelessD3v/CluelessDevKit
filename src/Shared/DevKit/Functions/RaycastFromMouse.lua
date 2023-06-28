local camera = workspace.CurrentCamera

local function RaycastFromMouse(mouse, distance, raycastParams): RaycastResult
    local unitRay: Ray  = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local rayCastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * distance, raycastParams)
    return rayCastResult
end


return RaycastFromMouse