-- stylua: ignore start
local Classes   = script.Classes
local Functions = script.Functions
local Libraries = script.Libraries

local DevKit = {}

DevKit.Classes = {
	ClampedNumber = require(Classes.ClampedNumber),
	Observable    = require(Classes.Observable),
	RbxToolTip    = require(Classes.Tooltip),
}

DevKit.Functions = {
	Color3Lerp             = require(Functions.Color3Lerp),
	GetSimpleID            = require(Functions.GetSimpleID),
	ScaleValuesToRange     = require(Functions.ScaleValuesToRange),
	TableToString          = require(Functions.TableToString),
	TranslateLinearIndex   = require(Functions.TranslateLinearIndex),
	Vec3ToVec3i16          = require(Functions.V3ToV3i16),
	WeightedChoice         = require(Functions.WeightedChoice),
	SetPreviewCameraCFrame = require(Functions.SetPreviewCameraCFrame),
}

DevKit.Libraries = {
	FindTagged       = require(Libraries.FindTagged),
	Noise            = require(Libraries.Noise),
	Ragdoll          = require(Libraries.Ragdoll),
	RaycastFromMouse = require(Libraries.RaycastFromMouse),
	SetOperations    = require(Libraries.SetOperations),
	Connect          = require(Libraries.Connect),
	Cupboard         = require(Libraries.Cupboard),
}
-- stylua: ignore end

return DevKit
