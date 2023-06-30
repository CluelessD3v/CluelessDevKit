--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local PlayerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local module = {}

do
	local screenGui = Instance.new("ScreenGui")
	module.screenGui = screenGui :: ScreenGui
	screenGui.Name = "Tooltip"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 10
	screenGui.Parent = PlayerGui :: PlayerGui
end

do
	local frame = Instance.new("Frame")
	module.frame = frame :: Frame
	frame.Name = "Tooltip"
	frame.AutomaticSize = Enum.AutomaticSize.XY
	frame.Size = UDim2.fromScale(0.2, 0.1)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 2
	frame.Visible = false
	frame.Parent = module.screenGui
end

do
	local textLabel = Instance.new("TextLabel")
	module.textLabel = textLabel :: TextLabel
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.Parent = module.frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Parent = textLabel
end

module.connections = {} :: {
	[GuiObject]: {
		mouseEnter: RBXScriptConnection,
		mouseMoved: RBXScriptConnection,
		mouseExit: RBXScriptConnection,
	},

	tagRemoved: RBXScriptConnection?,
}

module.tag = "Tooltip"
module.offset = Vector2.new(0, 0)
module.anchor = Vector2.new(0, 0)

local showTooltip = function(instance: GuiObject)
	assert(instance:IsA("GuiObject"), "instance must be a GuiObject")
	assert(instance:GetAttribute(module.tag), "instance must have the tooltip attribute")

	return function()
		module.frame.Position = UDim2.fromOffset(mouse.X + module.offset.X, mouse.Y + module.offset.Y)
		module.textLabel.Text = instance:GetAttribute(module.tag)
		module.frame.Visible = true
	end
end

local hideTooltip = function()
	module.frame.Visible = false
end

module.get = {}

module.get.tag = function()
	return module.tag
end

module.get.offset = function()
	return module.offset
end

module.get.anchor = function()
	return module.anchor
end

module.get.started = function()
	return not not module.connections.tagRemoved
end

module.set = {}

module.set.tag = function(tag: string)
	module.tag = tag
end

module.set.offset = function(offset: Vector2)
	module.offset = offset
end

module.set.anchor = function(anchor: Vector2)
	module.frame.AnchorPoint = anchor
	module.anchor = module.frame.AnchorPoint
end

module.add = function(instance: GuiObject, tooltip: string)
	instance:SetAttribute(module.tag, tooltip)
	CollectionService:AddTag(instance, module.tag)
end

module.remove = function(instance: GuiObject)
	instance:SetAttribute(module.tag, nil)
	CollectionService:RemoveTag(instance, module.tag)
end

module.start = function()
	if module.connections.tagRemoved then
		return
	end

	local tagged = CollectionService:GetTagged(module.tag)

	for _, instance in tagged do
		local gui = instance :: GuiObject
		local show = showTooltip(gui)
		module.connections[gui] = {
			mouseEnter = gui.MouseEnter:Connect(show),
			mouseMoved = gui.MouseMoved:Connect(show),
			mouseExit = gui.MouseLeave:Connect(hideTooltip),
		}
	end

	module.connections.tagRemoved = CollectionService:GetInstanceRemovedSignal(module.tag):Connect(function(instance)
		local gui = instance :: GuiObject
		for _, connection in pairs(module.connections[gui]) do
			connection:Disconnect()
		end
		module.connections[gui] = nil
	end)
end

module.stop = function()
	if not module.connections.tagRemoved then
		return
	end

	module.connections.tagRemoved:Disconnect()
	module.connections.tagRemoved = nil

	for _, connection in module.connections do
		for _, connection in pairs(connection) do
			connection:Disconnect()
		end
	end

	table.clear(module.connections)

	hideTooltip()
end

return module
