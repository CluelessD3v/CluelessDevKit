--[[
    Utility class to make "Observable" values, I reccommend it's used for primitive data types, i.e: 
    string, number, bool; Or non Instance Data types, i.e: Vector3, Vector2, BrickColor.

    !NOTE: Value type IS NOT ENFORCED, Changing the value type at runtime (String -> number) is allowed 
    !BUT NOT recommended! 
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Signal   = require(Packages.signal)


export type Observable = {
    Value   : any,
    Changed : RBXScriptSignal
}


local Observable = {} 
Observable.__index = Observable

function Observable.new(value): Observable
    local self = setmetatable({}, Observable)
    
    self.Value   = value
    self.Changed = Signal.new()


    local proxy = setmetatable({}, {
        __index = function(_, k)
            if not self[k] then
                error(k.." is not a valid member of Part Observable")
            end

            return if self[k] then self[k] else nil
        end,


        __newindex = function(_, k, v)
             --# Prevent changed signal from being overwwritten
            if k == "Changed" then
                error("Attempted to modify readonly property:", k)
            end

            if k == "Value" then
                self.Value = v
                self.Changed:Fire(v)
            end

            if not self[k] then
                error("Attempted to index:".. tostring(k).. " to Observable")
            end
        end,

        __tostring = function()
            return "Value: "..tostring(self.Value)
        end
    })

    return proxy
end
    

return Observable