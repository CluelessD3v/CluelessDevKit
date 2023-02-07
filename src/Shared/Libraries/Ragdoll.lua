--[[
    Credit to Gusshiy for the logic of this script, logic found here
    https://devforum.roblox.com/t/how-can-i-make-a-r-to-ragdoll-script/942730
]]

local module = {}

--+ Converts the character into a ragdoll, the model must have a humanoid!
module.RagdollCharacter = function(character: Model)
    local Humanoid: Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then 
        warn("No humanoid found in", character)
        return 
    end

    for _, descendant in pairs(character:GetDescendants()) do
        if descendant:IsA("Motor6D") and descendant.Parent.Name ~= "HumanoidRootPart" then
            local Motor6D = descendant
            local Socket  = Instance.new("BallSocketConstraint")
            local a1      = Instance.new("Attachment")
            local a2      = Instance.new("Attachment")
            
            a1.Parent = Motor6D.Part0
            a2.Parent = Motor6D.Part1
            
            Socket.Parent      = Motor6D.Parent
            Socket.Attachment0 = a1
            Socket.Attachment1 = a2
            
            a1.CFrame = Motor6D.C0
            a2.CFrame = Motor6D.C1
            
            Socket.LimitsEnabled      = true
            Socket.TwistLimitsEnabled = true
            
            Motor6D:Destroy()
        end
    end

    Humanoid.RequiresNeck = false
    Humanoid.Sit = true
    
    Humanoid.WalkSpeed  = 0
    Humanoid.JumpHeight = 0
end


--+ Turns a ragdolled character back to normal, since Ragdoll() if the
--+ character is not a ragdoll then it will not do anything. Optionally,
--+ pass walk speed and jump height arguments (the orignal values, for example)
--+ since Ragdoll() sets those to 0. Else it'll uses the default values.  
module.UnRagdollCharacter = function(character: Model, walkSpeed: number, JumpHeight:number)
    local Humanoid: Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then 
        warn("No humanoid found in", character)
        return 
    end

    for _ , descendant in pairs(character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") then
            local BallSocketConstraint = descendant
            BallSocketConstraint.UpperAngle      = 0
            BallSocketConstraint.TwistUpperAngle = 0
            BallSocketConstraint.TwistLowerAngle = 0

            local Joints = Instance.new("Motor6D")
            Joints.Parent = BallSocketConstraint.Parent

            Joints.Part0 = BallSocketConstraint.Attachment0.Parent
            Joints.Part1 = BallSocketConstraint.Attachment1.Parent
            Joints.C0    = BallSocketConstraint.Attachment0.CFrame
            Joints.C1    = BallSocketConstraint.Attachment1.CFrame
            
            BallSocketConstraint:Destroy()
        end
    end

    character.Humanoid.Sit = false
    Humanoid.WalkSpeed = walkSpeed or 16
    Humanoid.JumpHeight = JumpHeight or 7.2
    Humanoid.RequiresNeck = true

end

return module