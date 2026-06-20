local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)
local InstanceController = require(script.Parent.InstanceController)

local Orbit = {}

-- Returns the offset position in the orbit from the center.
function Orbit:PositionFromTime(body: Types.Body)
	if body.Orbit == nil then return 0 end
	local angle = (body.OrbitStart + InstanceController.Active.Time * self.AnglePerSecond) % 360
	angle = math.rad(angle)
	local angleInOrbit = CFrame.new(0,0,0) * body.Orbit.Angle * CFrame.Angles(0, angle, 0)
	local posInOrbit = angleInOrbit * Vector3.new(body.Orbit.Distance,0,0) -- TODO apply shape factor
	
	return angle
	
end

return Orbit