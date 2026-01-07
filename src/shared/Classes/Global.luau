local Global = {}

local RunService = game:GetService("RunService")
local activeTick 

Global.Time = 10

function Global.Tick(timePerSecond:number)
	
	if activeTick ~= nil then activeTick:Disconnect() end
	
	activeTick = RunService.RenderStepped:Connect(function(dt)		
		Global.Time	+= dt * timePerSecond
	end)
	
end

function Global.SetStandingPlanet(body)
	
	Global.Standing = body
	
end

Global.Tick(360)

return Global
