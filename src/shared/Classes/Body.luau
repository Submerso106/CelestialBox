local Body = {}
Body.__index = Body

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Global = require(script.Parent.Global)

Body.bodies = {}
local standing
local atmosphereID = "rbxassetid://114809383998298"

export type Body = {
	Angle: CFrame,
	Color:Color3,
	DaySize:number,
	Diameter:number,
	Display:SurfaceGui,
	DisplayModel:Model,
	Model:Model,
	Name:string,
	OrbitAngle:CFrame,
	OrbitDistance:number,
	OrbitStartAngle:number,
	Orbiting:Model & Body,
	YearSize:number,
	Info: {
		AnglePerDay:number,
		AnglePerHour:number,
		AnglePerMinute:number,
		AnglePerSecond:number,
		OrbitCompletion:number
	},

    UpdateInfo: (self: Body) -> (),
}

function Body.GetBody(model: Model?): Body
	print(model)
	if model ~= nil then
		print("With Model")
		return Body.bodies[model] 
	end
	print(Body.bodies)
	return Body.bodies
	
end

function Body.New(model: Model)
	
	local model = model ~= nil and model or Instance.new("Model")
	print(model)
	
	local info = setmetatable({ -- TODO Talvez não precise disso
		AnglePerDay = 0,
		AnglePerHour = 0,
		AnglePerMinute = 0,
		AnglePerSecond = 0,
		OrbitCompletion = 0,
		Rotation = 0		
	}, Body)
	info.__index = info
	info.__newindex = function(table, index, value)
		info[index] = value
	end
	
	local self = setmetatable({
		Angle = CFrame.Angles(0,0,0),
		Color = model.Part.Color,--Color3.new(1,1,1),
		DaySize = 24,
		Diameter = 10,
		Display = Instance.new("SurfaceGui"),
		DisplayModel = model:Clone(),
		Model = model,
		Name = "",
		OrbitAngle = CFrame.Angles(0,0,0),
		OrbitDistance = 10,
		OrbitStart = 0,
		Orbiting = nil,
		YearSize = 365,
		Test = 0,
		Info = info
	}, info)
	
	if player.PlayerGui:FindFirstChild("AstralBox") == nil then
		local folder = Instance.new("Folder")
		folder.Name = "AstralBox"
		folder.Parent = Players.LocalPlayer.PlayerGui
	end
	
	local part = Instance.new("Part")
	part.Size = Vector3.one * 1024
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = workspace.AstralBox
	part.Transparency = 1
	
	print(part)

	self.Display.MaxDistance = 2000
	self.Display.LightInfluence = 0
	self.Display.Enabled = false
	self.Display.Parent = player.PlayerGui.AstralBox
	self.Display.ClipsDescendants = false
	self.Display.Adornee = part
	
	local viewPort = Instance.new("ViewportFrame")
	viewPort.Parent = self.Display
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
	self.DisplayModel.Parent = viewPort
	
	local atmosphere = Instance.new("ImageLabel")
	atmosphere.BackgroundTransparency = 1
	atmosphere.Image = atmosphereID
	atmosphere.Parent = viewPort
	atmosphere.AnchorPoint = Vector2.new(0.5, 0.5)
	atmosphere.Position = UDim2.new(0.5, 0, 0.5, 0)
	atmosphere.Size = UDim2.new(1.2,0,1.2,0)
	atmosphere.ZIndex = 0
	atmosphere.ImageColor3 = self.Color
	atmosphere.ImageTransparency = 1
	
	self.AnglePerDay = 360 / self.YearSize
	self.AnglePerHour = self.AnglePerDay / self.DaySize
	self.AnglePerMinute = self.AnglePerHour / 60
	self.AnglePerSecond = self.AnglePerMinute / 60
	self.OrbitCompletion = 0

	Body.bodies[model] = self
	
	return self
	
end

function Body:UpdateInfo()
	
	self.AnglePerDay = 360 / self.YearSize
	self.AnglePerHour = self.AnglePerDay / self.DaySize
	self.AnglePerMinute = self.AnglePerHour / 60
	self.AnglePerSecond = self.AnglePerMinute / 60
	self.OrbitCompletion = 0
	
end

function Body:Update() -- TODO Adicionar opção de iniciar rotação no sentido da orbita
	
	if self.Orbiting == nil	then return end
	self = self :: Body
	
	local orbitingPosition = self.Orbiting.Type == Body and self.Orbiting.Model:GetPivot().Position or self.Orbiting:GetPivot().Position
	local orbitCFrame = CFrame.new(orbitingPosition) * self.OrbitAngle * CFrame.Angles(0, self:OrbitFromTime(true), 0)
	local cframe = CFrame.new(orbitCFrame * Vector3.new(self.OrbitDistance,0,0)) * self.Angle * self.Rotation
	self.Model:PivotTo(cframe)
	
end

local tickers = {}

function Body:Activate()
	
	if self == Body then
		for index, body in Body.bodies do
			body:Activate()
		end	
		return
	end
	
	if tickers[self] ~= nil then return end
	local display = self.Display
	--display.Adornee = player.Character.Anchor
	print(self, self.Display)
	if self ~= Global.Standing then display.Enabled = true end
	
	tickers[self] = RunService.RenderStepped:Connect(function(dt)		
		self:Update()
		if self ~= Global.Standing then
			self.DisplayModel.PrimaryPart:PivotTo(self.Model:GetPivot())
			local displayModelPos = self.DisplayModel:GetPivot().Position
			local locatorPos = Global.Standing.Model.Locator.Position
			local camPos = workspace.CurrentCamera:GetPivot().Position
			local direction = (displayModelPos - locatorPos).Unit
			local distance = (locatorPos - displayModelPos).Magnitude
			local displayPos = camPos + direction * (1512 + distance)
			local size = (camPos - displayPos).Magnitude * ((self.Diameter * 1 / 2) / distance * 1) --(3 / (math.sqrt(3) * distance)) * 50
			local lightDirection = (workspace.Sun:GetPivot().Position - displayModelPos).Unit
			lightDirection = Vector3.new(lightDirection.X, -lightDirection.Y, lightDirection.Z)
			display.ViewportFrame.Camera.CFrame = CFrame.new(displayModelPos + direction * self.Diameter, displayModelPos)
			display.ViewportFrame.LightDirection = lightDirection
			display.ViewportFrame.Size = UDim2.new(0, size, 0, size)
			if display.Adornee == nil then warn("Body Display Has a problem", self.Model) return end
			display.Adornee.CFrame = CFrame.new(displayPos, camPos)
		end
	end)
	
end

function Body:Deactivate()
	
	if self == Body then
		for index, body in Body.bodies do
			body:Deactivate()
		end
	end
	
	if tickers[self] ~= nil then 
		tickers[self]:Disconnect() 
		tickers[self] = nil
		self.Display.Enabled = false
	end
	
end

--function Body:TimeFromOrbit()

--	if OrbitAngle == nil then OrbitAngle = values.OrbitAngle.Value end

--	local Time = OrbitAngle / AnglePerDay

--	values.Day.Value = math.floor(Time)
--	values.Hour.Value = math.floor((Time - Day) / AnglePerHour)
--	values.Minute.Value = math.floor((Time - Day - Hour) / AnglePerMinute)
--	values.Second.Value = math.floor((Time - Day - Hour - Minute) / AnglePerSecond)

--end

function Body:OrbitFromTime(returnAsRad: boolean?) -- TODO ver ser o negócio de guardar a info separada não vai dar problema
	
	self = self :: Body	
	local orbit = (self.OrbitStart + Global.Time * self.AnglePerSecond) % 360
	self.OrbitCompletion = orbit
	self.Rotation = CFrame.Angles(0,math.rad(Global.Time * (360 / self.DaySize / 3600)),0)
	if returnAsRad then orbit = math.rad(orbit) end
	
	return orbit
	
end

return Body
