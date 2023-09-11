local cupboard = require(game.ReplicatedStorage.DevKit.Libraries.Cupboard)
local CS = game:GetService("CollectionService")
----- Test ------
-- local function onRemoved(_, k, oldV)
-- 	print("removed", k, oldV)
-- end

-- local function onInserted(_, k, v)
-- 	print("Added", k, v)
-- end

-- local idle = cupboard.wrap({}, true, {
-- 	OnInserted = function(this, k, v)
-- 		this[v] = os.clock()
-- 	end,
-- })

-- for _, v in CS:GetTagged("Knight") do
-- 	idle[v] = true
-- end

-- local roamingDistance = 25
-- local conns = {}
-- local roaming = cupboard.wrap({}, false, {
-- 	OnInserted = function(this, entity, v)
-- 		local Humanoid = entity:FindFirstChild("Humanoid") :: Humanoid
-- 		if Humanoid then
-- 			local randAngle = math.pi * 2 * math.random()
-- 			local x = math.cos(randAngle)
-- 			local y = Humanoid.HipHeight
-- 			local z = math.sin(randAngle)
-- 			Humanoid:MoveTo(entity:GetPivot().Position + Vector3.new(x, y, z) * roamingDistance)

-- 			conns[entity] = {}
-- 			conns[entity].MoveTo = Humanoid.MoveToFinished:Once(function()
-- 				print(entity.Name, "reached destination")
-- 				print(this)
-- 				this[entity] = nil
-- 				idle[entity] = true
-- 			end)
-- 		end
-- 	end,

-- 	OnRemoved = function(_, k)
-- 		print("removed")
-- 		local thisConns = conns[k]
-- 		for _, conn in thisConns do
-- 			conn:Disconnect()
-- 		end

-- 		idle[k] = os.clock()
-- 	end,
-- })

-- while task.wait() do
-- 	for knight, ts in idle do
-- 		if (os.clock() - ts) >= 5 then
-- 			idle[knight] = nil
-- 			roaming[knight] = true
-- 		end
-- 	end
-- end

local t = { "jame", "craig" }

cupboard.wrap(t, true, {
	onRemoved = function(_, k, v)
		print("removed", k, v)
	end,
	onInserted = function(_, k, v)
		print("inserted", k, v)
	end,
	onReplaced = function(_, k, v)
		print("replaced", k, v)
	end,
})

t[1] = "dion"

print(t)
