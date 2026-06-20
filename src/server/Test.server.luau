local RunService = game:GetService("RunService")

local Sun = workspace.SunTest
local Planet = workspace.OrbitTest

Sun.CFrame = CFrame.new(-20,10,0)

local AnglePerSecond = 90
local t = 0

RunService.Heartbeat:Connect(function(dt)

    local distance = 10
    local angle = math.rad(t)
    local facX, facZ = 1, 0.5
    local T = math.sqrt(facX * facX - facZ * facZ)
    local x, z = math.sin(angle) * facX - T, math.cos(angle) * facZ
    local r = math.sqrt(x*x + z*z)
    local angularSpeed = AnglePerSecond * (1 / r)
    t += angularSpeed * dt
    local orbitTilt = CFrame.Angles(math.rad(45),0,0)
    local posOffset = CFrame.new(x * distance,0,z * distance)
    local center = Sun.CFrame
	Planet.CFrame = center * orbitTilt * posOffset
	
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CelestialBoxController = require(ReplicatedStorage.Shared.CelestialBoxController)
local Body = require(ReplicatedStorage.Shared.Controllers.BodyController)
local Instance = require(ReplicatedStorage.Shared.Controllers.InstanceController)

task.wait(1)

local body = Body.New(workspace.TestPlanet)
body.Orbiting = workspace.Sun
body.YearSize = 2
body.DaySize = 1
body.OrbitAngle = CFrame.Angles(math.rad(45),0,0)
body.OrbitDistance = 20
body:UpdateInfo()

local standing = Body.New(workspace.StandingPlanet)
standing.Orbiting = workspace.Sun
standing.YearSize = 3
standing.DaySize = 1.5
standing.OrbitDistance = 40
--standing.Angle = CFrame.Angles(math.rad(45), math.rad(30), 0)
standing:UpdateInfo()

local sun = Body.New(workspace.Sun)
sun.Orbiting = nil
sun.Diameter = 3
sun:UpdateInfo()

local planet2 = Body.New(workspace.TestPlanet2)
planet2.Orbiting = workspace.TestPlanet
planet2.YearSize = 3
planet2.DaySize = 2
planet2.OrbitAngle = CFrame.Angles(math.rad(30),0,0)
planet2.OrbitDistance = 20
planet2.Diameter = 1
planet2:UpdateInfo()

local planet3 = Body.New(workspace.TestPlanet3)
planet3.Orbiting = workspace.Sun
planet3.YearSize = 5
planet3.DaySize = 0.5
planet3.OrbitAngle = CFrame.Angles(math.rad(80),math.rad(90),0)
planet3.OrbitDistance = 30
planet3.Diameter = 5
planet3:UpdateInfo()

local planet4 = Body.New(workspace.TestPlanet4)
planet4.Orbiting = workspace.Sun
planet4.YearSize = 8
planet4.DaySize = 2
planet4.OrbitAngle = CFrame.Angles(math.rad(-30),0,math.rad(30))
planet4.OrbitDistance = 60
planet4.Diameter = 20
planet4:UpdateInfo()

Instance.SetActive(standing)
CelestialBoxController:Init()

Body:Activate()
