local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Transforms = ReplicatedStorage.Transforms
local Raycast = require(Transforms.Raycast)

--[=[
	@class Weld
	Weld is a utility module for managing welds and motors between parts. This is the preferred way to connect parts together in the game.
]=]
local Module = {}

local function getName(name: string, instance1: Instance, instance2: Instance)
	return name .. instance1.Name .. instance2.Name
end

--[=[
	@within Weld
	Welds two parts together using a WeldConstraint. Preserves their relative position and orientation. Parents the weld to the second part.
]=]
function Module.weldParts(part1: BasePart, part2: BasePart)
	local weld = Instance.new("WeldConstraint")
	weld.Name = getName("Weld", part1, part2)
	weld.Part0 = part1
	weld.Part1 = part2
	return weld
end

--[=[
	@within Weld
	Sets up a new motor to connect the two parts together that preserves the relative position and orientation of the parts.
]=]
function Module.motorParts(part1: BasePart, part2: BasePart)
	local motor = Instance.new("Motor6D")
	motor.Name = getName("Motor", part1, part2)
	motor.Part0 = part1
	motor.Part1 = part2
	motor.C0 = part1:GetPivot():Inverse()
	motor.C1 = part2:GetPivot():Inverse()
	return motor
end

--[=[
	@within Weld
	Weld two models with PrimaryParts together. This is useful for creating a model that is a combination of multiple models.
]=]
function Module.weldModels(model1: Model, model2: Model)
	local weld = Instance.new("WeldConstraint")
	weld.Name = getName("Weld", model1, model2)
	weld.Part0 = model1.PrimaryPart
	weld.Part1 = model2.PrimaryPart
	return weld
end

--[=[
	@within Weld
	Stacks the WeldConstraint Part1 to the instance of a raycast result -> Part0

	--//XXX this functions is naturally inflexible because it demands a specific weld structure
]=]
function Module.toResult(weld: WeldConstraint, result: RaycastResult)
	local part0 = weld.Part0
	local part1 = result.Instance

	--//TODO make the offset and optional arg
	-- Define and set pivot
	local target = result.Position + part1:GetPivot().LookVector
	local pivot = CFrame.lookAt(result.Position, target, result.Normal)
	local offset = 0.5 * part1.Size * Vector3.yAxis
	part0:PivotTo(pivot + offset)

	-- Weld to the instance
	task.wait()
	weld.Part1 = part1
end

--[=[
	@within Weld
	Welds the given model to the "ground" below it through raycast
]=]
function Module.weldToGround(child: Model)
	local primaryPart = child.PrimaryPart
	local weld = primaryPart.WeldPrimaryPrimary

	-- Raycast the map
	local rayOrigin = primaryPart.Position
	local rayDirection = Vector3.new(0, -10, 0)
	local ignoreList = { child }

	-- Find any part
	local result = Raycast.instanceToPart(rayOrigin, rayDirection, ignoreList)
	if not result then
		return
	end

	local basePart = result.Instance
	local model = basePart:FindFirstAncestorOfClass("Model")

	if model then
		weld.Part0 = basePart
	end
end

--[=[
	@within Weld
	Welds model internally to its PrimaryPart. This is useful for creating a model that is a combination of multiple models. Pulled from Project Exodus.
]=]
function Module.weldModel(
	model: Model,
	arguments: {
		blacklist: { Instance }?,
		recursive: boolean?,
	}?
)
	if not model.PrimaryPart then
		return
	end

	local args = arguments or {}
	local blacklist = args.blacklist or {}
	local recursive = args.recursive or false

	local descendants = model:GetChildren()

	for _, descendant in descendants do
		if not descendant:IsA("Folder") and not descendant:IsA("Model") and not descendant:IsA("BasePart") then
			continue
		end

		if descendant == model.PrimaryPart then
			continue
		end

		if table.find(blacklist, descendant) then
			continue
		end

		if descendant:IsA("BasePart") or descendant:IsA("Folder") then
			local children = descendant:GetChildren()
			table.move(children, 1, #children, #descendants + 1, descendants)
		end

		if descendant:IsA("Folder") then
			continue
		end

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = model.PrimaryPart

		if descendant:IsA("BasePart") then
			weld.Part1 = descendant
		elseif descendant:IsA("Model") then
			if recursive then
				Module.weldModel(descendant, arguments)
			end

			weld.Part1 = descendant.PrimaryPart
		end

		weld.Name = getName("Weld", weld.Part0, weld.Part1)
		weld.Parent = weld.Part1
	end
end

return Module
