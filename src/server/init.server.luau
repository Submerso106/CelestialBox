task.wait(1)
local RS = game:GetService("ReplicatedStorage")
local Light = game:GetService("Lighting")

local Camera = workspace.CurrentCamera

local Up = Vector3.yAxis

--Camera.CameraType = Enum.CameraType.Scriptable

local Displays = workspace.AstralBox.Displays
local Values = workspace.AstralBox.Values
local Objects = workspace.AstralBox.Objects

local Object_Values = Values.Objects
local Global_Values = Values.Global
local View_Values = Values.View
local Display_Values = Values.Displays

local Standing = View_Values.CurrentPlanet.Value
local Connections = Values:GetChildren()
local DisplayInstances = Displays:GetChildren()
local SavedObjectValues = Object_Values:GetChildren() --TODO Achar Nome Melhor??

local YearSize
local DaySize
local PlanetRadius

local a,b,c,d,e

local Seconds = 0
local Minutes = 0
local Hours = 0

local ViewOffSet = Vector3.zero -- TODO Achar um nome melhor

------------------------------------------------------------------------------------------------------

local Updates = {
	
	Sky = function(Body)
		
		local StandingBodyPos = Object_Values[Standing].Pos.Value
		
		if Body == nil then
			
			--g == Geographical Latitude t = ClockTime

			-- Sun Pos in the sky:

			-- X = tSin * gCos,
			-- Y = tCos * gCos,
			-- Z = gSin

			local ViewPos = View_Values.Pos.Value
			local ViewRot = View_Values.Rotation.Value
			local ViewOffset = (ViewPos - StandingBodyPos).Unit
			local Sphere = 0

			--local g = ViewOffset.Y == 0 and 0.01 or ViewOffset.Y
			--local t = math.atan2(ViewOffset.X, ViewOffset.Z)
			
			--local g = math.sin(math.rad(ViewRot.Y)) 
			--local t = math.cos(math.rad(ViewRot.X * bCos + ViewRot.Z * bSin)) --TODO ARRUMAR TUDODODOAPDWOPIDA
			
			local t,g = math.rad(workspace.TestY.Value), math.rad(workspace.TestX.Value)
			
			--print(StandingBodyPos, ViewPos, ViewPos - StandingBodyPos)
			
			-- Reminder: X and Y refer to the Sky Coordinates 
			
			local Base = math.sqrt((1 - math.cos(t)^2) * math.cos(g)^2) * math.sign(t) --TODO Achar um nome melhor
			
			local PosXAngle = 0--math.deg(math.atan2(ViewPos.Y, (Vector3.new(0, ViewPos.Y, 0) - ViewPos).Magnitude)) -- TODO Acho que aqui a segunda parte é pra ser o sol
			local RotXAngle = math.deg(Base)

			local PosYAngle = 0--math.deg(math.atan2(ViewPos.X, ViewPos.Z))
			local RotYAngle = -math.deg(math.acos(math.cos(t) / math.cos(math.asin(Base))))
		
			
			print(RotXAngle, RotYAngle, Base)


			Light.ClockTime = (PosYAngle + RotYAngle) % 360 / 15
			Light.GeographicLatitude = 23.5 + ((RotXAngle) + PosXAngle) 

			Light.Sky.SunAngularSize = math.deg(math.atan2(Object_Values.Sun.Diameter.Value, (View_Values.Pos.Value - Object_Values.Sun.Pos.Value).Magnitude)) * 2

			print(Light:GetSunDirection())

		end
		
	end,

	CFrame = function(BodyValues, Display)

		local AnglePerSecond = (360 / BodyValues.YearSize.Value / BodyValues.DaySize.Value / 60 / 60) -- TODO Excluir variavel??

		local DayRotationPerSecond = (360 / BodyValues.DaySize.Value / 60 / 60)

		local OrbitPos = AnglePerSecond * Seconds + BodyValues.OrbitStartAngle.Value

		local DayRotation = CFrame.Angles(0, math.rad(DayRotationPerSecond * Seconds), 0)

		if BodyValues.Orbiting.Value == "nil" then

			BodyValues.Pos.Value = Vector3.zero

		else

			BodyValues.Pos.Value = Vector3.new(math.cos(math.rad(OrbitPos)), 0, math.sin(math.rad(OrbitPos))) * BodyValues.OrbitDistance.Value + Object_Values[BodyValues.Orbiting.Value].Pos.Value

		end

		local BodyModel = Display[BodyValues.Name]
		BodyValues.AngleCFrame.Value = CFrame.new(BodyValues.Pos.Value + Display_Values[Display.Name].Pos.Value) * CFrame.Angles(math.rad(BodyValues.Angle.Value.X), math.rad(BodyValues.Angle.Value.Y), math.rad(BodyValues.Angle.Value.Z))
		BodyModel:PivotTo(BodyValues.AngleCFrame.Value * DayRotation)

		if BodyValues.Name == Standing then

			Display.Locator.CFrame = BodyModel.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(ViewOffSet * PlanetRadius))
			Display.LocatorBeam.CFrame = BodyModel.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(ViewOffSet * (PlanetRadius + 0.6)))
			Display.LocatorBeam2.CFrame = BodyModel.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(ViewOffSet * (PlanetRadius + 1)))
			Display.LocatorRod.CFrame = BodyModel.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(ViewOffSet * (PlanetRadius + 0.5), Display.LocatorBeam2.Position))
			
			View_Values.Pos.Value = Display.Locator.Position - Display.PrimaryPart.Position
			View_Values.Rotation.Value = Display.Locator.Orientation

		end

	end,

	Size = function(BodyValues, Display)

		local BodyModel:Model = Display[BodyValues.Name]

		BodyModel:ScaleTo(BodyValues.Diameter.Value)	

	end,

	Color = function(BodyValues, Display)

		local BodyModel = Display[BodyValues.Name]

		BodyModel.Part.Color = BodyValues.Color.Value

	end,

}

------------------------------------------------------------------------------------------------------

local function Rotate (XYZ, Initial, theta)

	local Rotated = Vector3.zero

	local tCos = math.cos(theta)
	local tSin = math.sin(theta)

	local Matrix = {

		X = function ()

			Rotated = Vector3.new(
				Initial.X,
				Initial.Y * tCos - Initial.Z * tSin,
				Initial.Y * tSin + Initial.Z * tCos)

		end,

		Y = function ()

			Rotated = Vector3.new(
				Initial.X * tCos + Initial.Z * tSin,
				Initial.Y,
				-Initial.X * tSin + Initial.Z * tCos)

		end,

		Z = function ()

			Rotated = Vector3.new(
				Initial.X * tCos - Initial.Y * tSin,
				Initial.X * tSin + Initial.Y * tCos,
				Initial.Z)

		end,

	}

	Matrix[XYZ]()

	return Rotated

end

local function PlaceLocator()

	ViewOffSet = Vector3.new(
		aCos * bCos,
		bSin,
		aSin * bCos
	)

	--ViewOffSet = Rotate("Z", ViewOffSet, d)
	--ViewOffSet = Rotate("X", ViewOffSet, c)
	--ViewOffSet = Rotate("Y", ViewOffSet, e)

	View_Values.Pos.Value = ViewOffSet

end

local function Update(ToUpdate, BodyValues, Display)

	if ToUpdate ~= nil then

		Updates[ToUpdate](BodyValues, Display)
		Updates["Sky"]()

	else

		for i, _ in Updates do

			Updates[i](BodyValues, Display)

		end

	end

end

local function CheckDisplayToUpdate(ToUpdate, BodyValues, Display)

	if Display ~= nil then

		Update(ToUpdate, BodyValues, Display)

	else

		for _, i in DisplayInstances do

			Update(ToUpdate, BodyValues, i)

		end

	end

end

local function CheckBodyToUpdate(ToUpdate, BodyValues, Display)

	if BodyValues ~= nil then

		CheckDisplayToUpdate(ToUpdate, BodyValues, Display)

	else

		for _, i in SavedObjectValues do

			CheckDisplayToUpdate(ToUpdate, i, Display)

		end

	end

end

local function PlaceSky(Body) --TODO Levar em consideração a rotação da terra



end

local function LoadBodyOnDisplay(BodyValues, Display)

	print(BodyValues, Display)

	local ViewModel = Objects[BodyValues.Name].SurfaceGui[BodyValues.Name][BodyValues.Name]
	ViewModel:ScaleTo(BodyValues.Diameter.Value)	
	ViewModel.Part.Color = BodyValues.Color.Value
	ViewModel:PivotTo(CFrame.new(BodyValues.Pos.Value) * CFrame.Angles(math.rad(BodyValues.Angle.Value.X), math.rad(BodyValues.Angle.Value.Y), math.rad(BodyValues.Angle.Value.Z)))

	local Model:Model = ViewModel:Clone()	
	Model.Parent = Display

	print(Model)

end

local function CheckDisplayToLoadBody(BodyValues, Display)

	if Display ~= nil then

		LoadBodyOnDisplay(BodyValues, Display)

	else

		for _, i in DisplayInstances do

			LoadBodyOnDisplay(BodyValues, i)

		end

	end

end

local function LoadDisplays(ToUpdate, Display)

	print(ToUpdate)

	if Display ~= nil then

		local NewDisplay = RS.DefaultModel.DefaultDisplay:Clone()
		NewDisplay.Name = Display.Name
		NewDisplay.Parent = Displays
		NewDisplay:PivotTo(CFrame.new(Display_Values[Display].Pos.Value))

	else

		for _, i in Display_Values:GetChildren() do

			if i:IsA("BoolValue") then continue end

			local NewDisplay = RS.DefaultModel.DefaultDisplay:Clone()
			NewDisplay.Name = i.Name
			NewDisplay.Parent = Displays
			NewDisplay:PivotTo(CFrame.new(i.Pos.Value))

		end

	end

	DisplayInstances = Displays:GetChildren()

	for _, i in SavedObjectValues do

		if i.Name == View_Values.CurrentPlanet.Value then

			PlanetRadius = Object_Values[Standing].Diameter.Value / 2

			a = math.rad(View_Values.AngleOnEquator.Value)
			b = math.rad(View_Values.AngleFromEquator.Value)

			aCos = math.cos(a)
			aSin = math.sin(a)
			bCos = math.cos(b)
			bSin = math.sin(b)

		end

		if Display_Values.Display.Value == true then

			CheckDisplayToLoadBody(i, Display)
			CheckBodyToUpdate(ToUpdate, i, Display)

		end

	end

end

local function LoadBodyInstance(Body)

	local NewPlanet = RS.DefaultModel.DefaultPlanet:Clone()
	NewPlanet.Parent = Objects
	NewPlanet.Name = Body.Name
	NewPlanet.SurfaceGui.DefaultPlanet.DefaultPlanet.Name = Body.Name
	NewPlanet.SurfaceGui.DefaultPlanet.Name = Body.Name

end

local function CheckBodyToLoadBodyInstance(BodyValues)

	if BodyValues ~= nil then

		LoadBodyInstance(BodyValues)	
		LoadBodyOnDisplay(BodyValues)
		PlaceSky(BodyValues)

	else

		for _, i in SavedObjectValues do

			LoadBodyInstance(i)	
			LoadBodyOnDisplay(i)
			PlaceSky(i)

		end

	end

	SavedObjectValues = Object_Values:GetChildren()

end

------------------------------------------------------------------------------------------------------

local Relations = { -- Alterar por uma função com if's vai ajudar na performace (pouco, mas vai)

	-- Planet --

	YearSize = function(BodyValues)

		YearSize = BodyValues.YearSize.Value

		local Body = Objects[BodyValues.Name].SurfaceGui[BodyValues.Name][BodyValues.Name]

		CheckBodyToUpdate("CFrame", Body)

	end,

	DaySize = function(BodyValues)

		DaySize = BodyValues.DaySize.Value

		local Body = Objects[BodyValues.Name].SurfaceGui[BodyValues.Name][BodyValues.Name]

		CheckBodyToUpdate("CFrame", Body)

	end,

	Diameter = function(BodyValues)

		local Body = Objects[BodyValues.Name].SurfaceGui[BodyValues.Name][BodyValues.Name]

		if Body.Name == Standing then 

			PlanetRadius = BodyValues.Diameter.Value / 2

			PlaceLocator() -- TODO Ver se Precisa

		end

		CheckBodyToUpdate("Size", Body)

	end,

	OrbitAngle = function(BodyValues)

		local Body = Objects[BodyValues.Name].SurfaceGui[BodyValues.Name][BodyValues.Name]

		CheckBodyToUpdate("CFrame", Body)

	end,

	Pos = function()

		PlaceLocator()

	end,

	Angle = function()

		c = math.rad(Values.Angle.Value)

		if Values.AngleX.Value >= 360 then 

			Values.AngleX.Value -= 360 

		end

		PlaceLocator()

	end,
	
	AngleCFrame = function()
		
		
		
	end,

	-- View --

	AngleOnEquator = function()

		a = math.rad(View_Values.AngleOnEquator.Value)

		if View_Values.AngleOnEquator.Value >= 360 then 

			View_Values.AngleOnEquator.Value -= 360 

		end

		aCos = math.cos(a)
		aSin = math.sin(a)

		PlaceLocator()

	end,

	AngleFromEquator = function()

		b = math.rad(View_Values.AngleFromEquator.Value)

		if View_Values.AngleFromEquator.Value > 90 then 

			View_Values.AngleFromEquator.Value = -180 + b

		end

		bCos = math.cos(b)
		bSin = math.sin(b)

		PlaceLocator()

	end,

	CurrentPlanet = function()

		Standing = View_Values.CurrentPlanet.Value

		PlanetRadius = Object_Values[Standing].Diameter.Value / 2

	end,
	
	Rotation = function()
		
		
		
	end,

	-- Orbits --

	OrbitDistance = function()

		PlaceSky(nil)

	end,

	-- Global --

	Time = function()

		Seconds = Global_Values.Time.Value

		CheckBodyToUpdate("CFrame")

	end,

}

local function AddConnection(Value)

	if Value:IsA("Folder") then	

		for _, i in Value:GetChildren() do

			AddConnection(i)

		end

		return

	end

	Value:GetPropertyChangedSignal("Value"):Connect(function()

		Relations[Value.Name](Value.Parent)

	end)

end

for _, i in Connections do

	AddConnection(i)

end

Values.DescendantAdded:Connect(function(Child)

	if Child:IsA("Folder") then	

		for _, i in Child:GetChildren() do

			AddConnection(i)

		end

	end

	AddConnection(Child)

end)

CheckBodyToLoadBodyInstance()
LoadDisplays()

local Test = false

while Test do

	Global_Values.Time.Value += workspace.TimePerSecond.Value

	task.wait(workspace.WaitPeriod.Value)

end

local function PerformaceTest(testvar, t2, Times)

	local test = 0

	local Time = tick()

	for	i = 0, Times, 1 do

		local test = Test(testvar, t2)

	end

	print(tick() - Time)

	task.wait(1)

	local Time = tick()


	for	i = 0, Times, 1 do


	end

	print(tick() - Time)

end

--PerformaceTest(2, true, 1000000)

workspace.TestX.Changed:Connect(function()
	
	Updates["Sky"]()
	
end)

workspace.TestY.Changed:Connect(function()

	Updates["Sky"]()

end)





