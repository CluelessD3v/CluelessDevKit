local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Module = {}

local function onPlayerTouched(callback: (player: Player, character: Model) -> ())
	return function(otherPart: BasePart)
		local otherPlayer, otherCharacter = Module.getPlayerFromPart(otherPart)
		if otherPlayer and otherCharacter then
			callback(otherPlayer, otherCharacter)
		end
	end
end

function Module.getPlayerFromPart(basePart: BasePart): (Player?, Model?)
	local character = basePart:FindFirstAncestorWhichIsA("Model")
	if not character then
		return nil, nil
	end

	return Players:GetPlayerFromCharacter(character), character
end

function Module.playerTouched(part: BasePart, callback: (player: Player, character: Model) -> ())
	return part.Touched:Connect(onPlayerTouched(callback))
end

function Module.playerTouchEnded(part: BasePart, callback: (player: Player, character: Model) -> ())
	return part.TouchEnded:Connect(onPlayerTouched(callback))
end

function Module.playerClicked(detector: ClickDetector, callback: (player: Player) -> ())
	return detector.MouseClick:Connect(callback)
end

function Module.tag<T>(tag: string, added: (T) -> (), removed: (T) -> ())
	local addedConnection = CollectionService:GetInstanceAddedSignal(tag):Connect(added)
	local removedConnection = CollectionService:GetInstanceRemovedSignal(tag):Connect(removed)
	for _, tagged in CollectionService:GetTagged(tag) do
		added(tagged)
	end

	return addedConnection, removedConnection
end

function Module.propertyChanged(instance: Instance, property: string, callback: (any) -> ())
	local connection = instance:GetPropertyChangedSignal(property):Connect(function()
		callback(instance[property])
	end)
	callback(instance[property])
	return connection
end

function Module.attributeChanged(instance: Instance, attribute: string, callback: (any) -> ())
	local connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
		callback(instance:GetAttribute(attribute))
	end)
	callback(instance:GetAttribute(attribute))
	return connection
end

function Module.valueChanged(instance: ValueBase, callback: (any) -> ())
	local connection = instance.Changed:Connect(callback)
	callback(instance.Value)
	return connection
end

local function disconnect(connection: Connection)
	if
		typeof(connection) == "RBXScriptConnection"
		or (typeof(connection) == "table" and type(connection.Disconnect) == "function")
	then
		(connection :: RBXScriptConnection):Disconnect()
	elseif typeof(connection) == "thread" then
		task.cancel(connection)
	elseif typeof(connection) == "Instance" then
		pcall(connection.Destroy, connection)
	elseif typeof(connection) == "function" then
		connection()
	end
end

function Module.disconnect<T>(connections: { [T]: Connection }, key: T?)
	if key then
		local connection = connections[key]
		if connection then
			disconnect(connection)
			connections[key] = nil
		end
	else
		for _, connection in connections do
			disconnect(connection)
		end

		table.clear(connections)
	end
end

export type Connection = RBXScriptConnection | { Disconnect: (any) -> () } | thread | Instance

return Module
