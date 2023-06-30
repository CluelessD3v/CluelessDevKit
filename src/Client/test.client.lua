local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local RBXToolTip = require(Packages.rbxtooltip)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local SG = PlayerGui:WaitForChild("ScreenGui") :: ScreenGui
local Frame = SG.Frame :: Frame

-- stylua: ignore start
local tooltip = RBXToolTip.fromText("This is a test for the wonderful tool sona made for me :3", Vector2.new(0.5, 0.5), Vector2.new(0.5, 0.5))
-- stylua: ignore end
tooltip:Enable()
tooltip:Add(Frame)
function tooltip:OnMoved()
	print("Moving")
end
