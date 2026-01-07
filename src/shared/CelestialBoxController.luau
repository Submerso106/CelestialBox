local AstralBox = {}

local Body = require(script.Parent.Classes.Body)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

function AstralBox:CharacterSetup(character)
	
	local camPos = workspace.CurrentCamera.CFrame.Position
	local humanoid = character.Humanoid
	local displayAnchor = Instance.new("Part")
	displayAnchor.Parent = character
	displayAnchor.Position = camPos
	displayAnchor.CanCollide = false
	displayAnchor.CanQuery = false
	displayAnchor.CanTouch = false
	displayAnchor.Anchored = true
	displayAnchor.Transparency = 1
	displayAnchor.Name = "Anchor"
	
	local connection = RunService.RenderStepped:Connect(function()
		if camPos ~= displayAnchor.Position then
			displayAnchor.Position = camPos
		end
	end)
	humanoid.Died:Connect(function()
		connection:Disconnect()
	end)
	
	local bodies = Body.GetBody()
	for index, body:Body.Body in bodies do
		body.Display.Adornee = displayAnchor
	end
	
	print(bodies)
	
end

function AstralBox:Init()
	
	if player.PlayerGui:FindFirstChild("AstralBox") == nil then
		local folder = Instance.new("Folder")
		folder.Name = "AstralBox"
		folder.Parent = Players.LocalPlayer.PlayerGui
	end
	
	player.CharacterAdded:Connect(function(char)
		print(char)
		self:CharacterSetup(char)
	end)
	if player.Character ~= nil then
		self:CharacterSetup(player.Character)
	end
	print("AstralBox Initiated") 
	
end

return AstralBox
