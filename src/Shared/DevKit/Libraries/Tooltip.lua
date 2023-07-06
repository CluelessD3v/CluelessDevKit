--!strict

--[[
	Module made by @SOLARSCUFFLE_BOT
	wally package link: https://wally.run/package/solarscuffle-bot/rbxtooltip?version=2.0.0
]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function nop(self) end
local function nopUDim2(self, Position: UDim2) end

local function connectGui(self: GuiToolTip, gui: GuiObject)
	self.connections[gui] = {
		enter = gui.MouseEnter:Connect(self.show),
		moved = gui.MouseMoved:Connect(self.move),
		leave = gui.MouseLeave:Connect(self.hide),
		destroying = gui.Destroying:Connect(function()
			self:Remove(gui)
		end),
	}
end

local function disconnectGui(self: GuiToolTip, gui: GuiObject)
	local connections = self.connections[gui]
	connections.enter:Disconnect()
	connections.moved:Disconnect()
	connections.leave:Disconnect()
	connections.destroying:Disconnect()
end

local function raycastFromMouse(mousePosition: Vector2, distance: number, raycastParams: RaycastParams?): RaycastResult?
	local unitRay: Ray = workspace.CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	return workspace:Raycast(unitRay.Origin, unitRay.Direction * distance, raycastParams)
end

local Module = {}

do
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.Visible = false

	Module.DefaultTextLabel = textLabel
end

function Module.Text(self: ToolTip, value: string?): string
	if value then
		(self.instance :: TextLabel).Text = value
	end -- sad type casting noises
	return (self.instance :: TextLabel).Text
end

function Module.Anchor(self: ToolTip, value: Vector2?): Vector2
	if value then
		self.instance.AnchorPoint = value
	end
	return self.instance.AnchorPoint
end

function Module.Offset(self: ToolTip, value: Vector2?): Vector2
	if value then
		self.offset = value
	end
	return self.offset
end

function Module.Update(self: ToolTip)
	local mousePosition = UserInputService:GetMouseLocation()
	self.instance.Position = UDim2.fromOffset(mousePosition.X + self.offset.X, mousePosition.Y + self.offset.Y)
	self:onUpdate(self.instance.Position)
end

Module.Destroy = {}

function Module.Destroy.Gui(self: GuiToolTip)
	Module.Disable.Gui(self)
	table.clear(self.guis)
	self.instance:Destroy()
end

function Module.Destroy.PV(self: PVToolTip)
	Module.Disable.PV(self)
	table.clear(self.pvs)
	self.instance:Destroy()
end

Module.IsEnabled = {}

function Module.IsEnabled.Gui(self: GuiToolTip)
	return self.connections[next(self.guis) :: GuiObject] == nil
end

function Module.IsEnabled.PV(self: PVToolTip)
	return self.hearbeat ~= nil
end

Module.Enable = {}

function Module.Enable.Gui(self: GuiToolTip)
	if Module.IsEnabled.Gui(self) then
		return
	end

	for gui in pairs(self.guis) do
		connectGui(self, gui)
	end
end

local function hide(self: ToolTip)
	if self.lastResult then
		self.instance.Visible = false
		self:onHidden()
	end
	self.lastResult = nil
end

function Module.Enable.PV(self: PVToolTip)
	if Module.IsEnabled.PV(self) then
		return
	end

	self.hearbeat = RunService.Heartbeat:Connect(function()
		local mouseLocation = UserInputService:GetMouseLocation()

		local result = raycastFromMouse(mouseLocation, self.distance, self.raycastParams)
		if not result then
			hide(self)
			return
		end

		local object: Instance? = result.Instance
		while not self.pvs[object] do
			if object == workspace or object == nil then
				hide(self)
				return
			end

			object = object and object.Parent
		end

		if not self.lastResult then
			self.instance.Visible = true
			self:onShown()
		elseif result.Position ~= self.lastResult.Position then
			self:onMoved(mouseLocation)
		end

		self.lastResult = result
	end)
end

Module.Disable = {}

function Module.Disable.Gui(self: GuiToolTip)
	if not Module.IsEnabled.Gui(self) then
		return
	end

	self.instance.Visible = false

	for gui in pairs(self.guis) do
		disconnectGui(self, gui)
	end

	table.clear(self.connections)
end

function Module.Disable.PV(self: PVToolTip)
	if not Module.IsEnabled.PV(self) then
		return
	end

	self.instance.Visible = false

	self.hearbeat:Disconnect()
	self.hearbeat = nil
end

Module.Add = {}

function Module.Add.Gui(self: GuiToolTip, gui: GuiObject)
	if self.guis[gui] then
		return
	end
	self.guis[gui] = true

	if not Module.IsEnabled.Gui(self) then
		return
	end
	connectGui(self, gui)
end

function Module.Add.PV(self: PVToolTip, pv: PVInstance)
	if self.pvs[pv] then
		return
	end
	self.pvs[pv] = true
end

Module.Remove = {}

function Module.Remove.Gui(self: GuiToolTip, gui: GuiObject)
	if not self.guis[gui] then
		return
	end
	if Module.IsEnabled.Gui(self) then
		disconnectGui(self, gui)
	end
	self.guis[gui] = nil
end

function Module.Remove.PV(self: PVToolTip, pv: PVInstance)
	if not self.pvs[pv] then
		return
	end
	self.pvs[pv] = nil
end

Module.From = {}

local function fromGui(gui: GuiObject, offset: Vector2, anchor: Vector2)
	gui.AnchorPoint = anchor

	local self = {
		instance = gui,
		offset = offset,
		connections = {},
		guis = {},

		onShown = nop,
		onHidden = nop,
		onMoved = nopUDim2,
		onUpdate = nopUDim2,

		Anchor = Module.Anchor,
		Offset = Module.Offset,
		Update = Module.Update,
		Destroy = Module.Destroy.Gui,
		Enable = Module.Enable.Gui,
		Disable = Module.Disable.Gui,
		Add = Module.Add.Gui,
		Remove = Module.Remove.Gui,
	}

	function self.show()
		self.instance.Visible = true
		self:onShown()
	end

	function self.move(X: number, Y: number)
		local WasHidden = not self.instance.Visible
		self.instance.Visible = true

		if WasHidden then
			self:onShown()
		end
		self:onMoved(UDim2.fromOffset(X, Y))
	end

	function self.hide()
		self.instance.Visible = false
		self:onHidden()
	end

	return self
end

function Module.From.Gui(gui: GuiObject, offset: Vector2, anchor: Vector2) -- Our constructors are not bound to any kind of class, we can have as many as we want for the same data
	gui.Visible = false
	return fromGui(gui, offset, anchor)
end

function Module.From.GuiText(text: string, offset: Vector2, anchor: Vector2): GuiToolTip & { Text: typeof(Module.Text) }
	local TextLabel = Module.DefaultTextLabel:Clone()
	TextLabel.Text = text

	local self = fromGui(TextLabel, offset, anchor) :: any
	self.Text = Module.Text
	return self
end

local function fromPV(
	gui: GuiObject,
	offset: Vector2,
	anchor: Vector2,
	distance: number?,
	raycastParams: RaycastParams?
)
	gui.AnchorPoint = anchor

	local self = {
		instance = gui,
		offset = offset,
		distance = distance or 2000,
		raycastParams = raycastParams,
		lastResult = nil :: RaycastResult?,
		heartbeat = nil :: RBXScriptConnection?,
		pvs = {},

		onShown = nop,
		onHidden = nop,
		onMoved = nopUDim2,
		onUpdate = nopUDim2,

		Anchor = Module.Anchor,
		Offset = Module.Offset,
		Update = Module.Update,
		Destroy = Module.Destroy.PV,
		Enable = Module.Enable.PV,
		Disable = Module.Disable.PV,
		Add = Module.Add.PV,
		Remove = Module.Remove.PV,
	}

	function self.show()
		self.instance.Visible = true
		self:onShown()
	end

	function self.move(X: number, Y: number)
		local WasHidden = not self.instance.Visible
		self.instance.Visible = true

		if WasHidden then
			self:onShown()
		end
		self:onMoved(UDim2.fromOffset(X, Y))
	end

	function self.hide()
		self.instance.Visible = false
		self:onHidden()
	end

	Module.Enable.PV(self)

	return self
end

function Module.From.PV(
	gui: GuiObject,
	offset: Vector2,
	anchor: Vector2,
	distance: number?,
	raycastParams: RaycastParams?
)
	gui.Visible = false
	return fromPV(gui, offset, anchor, distance, raycastParams)
end

function Module.From.PVText(
	text: string,
	offset: Vector2,
	anchor: Vector2,
	distance: number?,
	raycastParams: RaycastParams?
): PVToolTip
	local TextLabel = Module.DefaultTextLabel:Clone()
	TextLabel.Text = text

	local self = fromPV(TextLabel, offset, anchor, distance, raycastParams) :: any
	self.Text = Module.Text
	return self
end

export type GuiToolTip = typeof(Module.From.Gui(Instance.new("Frame"), Vector2.zero, Vector2.zero))
export type PVToolTip = typeof(Module.From.PV(Instance.new("Part")))
export type ToolTip = GuiToolTip | PVToolTip

return Module
