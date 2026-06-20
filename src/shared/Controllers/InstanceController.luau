local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local Instance = {}
Instance.Instances = {}
Instance.Active = nil

function Instance:New(name, activate: boolean?)
	local newInstance = {
		Name = name,
		Time = 0,
		TickPerSecond = 24,
		TimePerSecond = 100,
		Bodies = {},
	} :: Types.Instance
	newInstance.TimePerTick = newInstance.TimePerSecond / newInstance.TickPerSecond
	
	table.insert(Instance.Instances, newInstance)
	if activate then self:SetActive(newInstance) end
	return newInstance

end

function Instance.SetActive(instance: Types.Instance)
	Instance.Active = instance
	--TODO make bodies from other instances disappear, and make bodies from this instance appear
end

return Instance
