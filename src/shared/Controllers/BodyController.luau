local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)
local InstanceController = require(script.Parent.InstanceController)
local OrbitController = require(script.Parent.OrbitController)

local Body = {}

Body.Bodies = {}
local atmosphereID = "rbxassetid://114809383998298"

function Body:AnglePerSecond(body: Types.Body)
	if body.DaySize == nil or body.YearSize == nil then return 0 end
	local AnglePerDay = 360 / body.YearSize
	local AnglePerHour = AnglePerDay / body.DaySize
	local AnglePerSecond = AnglePerHour / 3600
	return AnglePerSecond
end

function Body.New(model: Model)
	local player = Players.submerso106
	
	local model = model ~= nil and model or Instance.new("Model")
	
	local body = {	
	} :: Types.Body
	
	if player.PlayerGui:FindFirstChild("AstralBox") == nil then
		local folder = Instance.new("Folder")
		folder.Name = "AstralBox"
		folder.Parent = Players.LocalPlayer.PlayerGui
	end -- TODO move to a specific client space
	
	local part = Instance.new("Part")
	part.Size = Vector3.one * 1024
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = workspace.AstralBox
	part.Transparency = 1

	body.Display.MaxDistance = 2000
	body.Display.LightInfluence = 0
	body.Display.Enabled = false
	body.Display.Parent = player.PlayerGui.AstralBox
	body.Display.ClipsDescendants = false
	body.Display.Adornee = part
	
	local viewPort = Instance.new("ViewportFrame")
	viewPort.Parent = body.Display
	viewPort.Size = UDim2.new(0,50,0,50)
	viewPort.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
	viewPort.Ambient = Color3.new(0,0,0)--Color3.fromRGB(100, 100, 255)
	viewPort.LightColor = Color3.new(1,1,1)
	viewPort.BackgroundTransparency = 1
	viewPort.ClipsDescendants = false
	viewPort.AnchorPoint = Vector2.new(0.5, 0.5)
	viewPort.Position = UDim2.new(0.5, 0, 0.5, 0)
	viewPort.ZIndex = 10
	
	local cam = Instance.new("Camera")
	cam.Parent = viewPort
	cam.FieldOfView = 60
	viewPort.CurrentCamera = cam
	body.DisplayModel.Parent = viewPort
	
	local atmosphere = Instance.new("ImageLabel")
	atmosphere.BackgroundTransparency = 1
	atmosphere.Image = atmosphereID
	atmosphere.Parent = viewPort
	atmosphere.AnchorPoint = Vector2.new(0.5, 0.5)
	atmosphere.Position = UDim2.new(0.5, 0, 0.5, 0)
	atmosphere.Size = UDim2.new(1.2,0,1.2,0)
	atmosphere.ZIndex = 0
	atmosphere.ImageColor3 = body.Color
	atmosphere.ImageTransparency = 1

	body.OrbitAnglePerSecond = Body:AnglePerSecond(body)
	body.OrbitCompletion = 0

	Body.Bodies[model] = body
	
	return body
	
end

function Body:UpdateInfo(body)
	
	body.AnglePerDay = 360 / body.YearSize
	body.AnglePerHour = body.AnglePerDay / body.DaySize
	body.AnglePerMinute = body.AnglePerHour / 60
	body.AnglePerSecond = body.AnglePerMinute / 60
	body.OrbitCompletion = 0
	
end

function Body:Update(body: Types.Body) -- TODO Adicionar opção de iniciar rotação no sentido da orbita	
	if body.Orbit == nil	then return end
	
	body.Rotation = CFrame.Angles(0,math.rad(InstanceController.Active.Time * (360 / body.DaySize / 3600)),0)
	local cframe = CFrame.new(posInOrbit * Vector3.new(body.Orbit.Distance,0,0)) * body.Angle * body.Rotation
	body.Model:PivotTo(cframe)
	
end

function Body:Activate(body)
	
	tickers[body] = RunService.RenderStepped:Connect(function(dt)		
		body:Update()
		if body ~= InstanceController.Active then
			body.DisplayModel.PrimaryPart:PivotTo(body.Model:GetPivot())
			local displayModelPos = body.DisplayModel:GetPivot().Position
			local locatorPos = InstanceController.Active.Model.Locator.Position
			local camPos = workspace.CurrentCamera:GetPivot().Position
			local direction = (displayModelPos - locatorPos).Unit
			local distance = (locatorPos - displayModelPos).Magnitude
			local displayPos = camPos + direction * (1512 + distance)
			local size = (camPos - displayPos).Magnitude * ((body.Diameter * 1 / 2) / distance * 1) --(3 / (math.sqrt(3) * distance)) * 50
			local lightDirection = (workspace.Sun:GetPivot().Position - displayModelPos).Unit
			lightDirection = Vector3.new(lightDirection.X, -lightDirection.Y, lightDirection.Z)
			display.ViewportFrame.Camera.CFrame = CFrame.new(displayModelPos + direction * body.Diameter, displayModelPos)
			display.ViewportFrame.LightDirection = lightDirection
			display.ViewportFrame.Size = UDim2.new(0, size, 0, size)
			if display.Adornee == nil then warn("Body Display Has a problem", body.Model) return end
			display.Adornee.CFrame = CFrame.new(displayPos, camPos)
		end
	end)
	
end

return Body
