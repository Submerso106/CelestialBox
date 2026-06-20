local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Types = require(ReplicatedStorage.Shared.Types)
local BodyController = require(script.Parent.BodyController)
local InstanceController = require(script.Parent.InstanceController)
local Update = {}

Update.Ticker = nil

function Update:Tick(instance, dt: number?)
    for index, body in pairs(instance.Bodies) do
        instance.Time += instance.Time + (dt or 1) / instance.TickPerSecond
        BodyController:Update(body)
    end
    
end

function Update:StartTicker()
    local instance: Types.Instance = InstanceController.Active
    if Update.Ticker ~= nil then return end
    if instance == nil then return end
    if instance.TickPerSecond == -1 then
        Update.Ticker = {
            Connection = RunService.OnRenderStepped:Connect(function(dt)
                Update.Ticker:Tick(instance, dt)
            end),
            Instance = instance,
        }
    else
        Update.Ticker = {
            Instance = instance,
        }
        while Update.Ticker ~= nil do
            local startTime = tick()
            Update.Ticker:Tick(instance)
            local elapsed = tick() - startTime -- Check if needed later
            local waitTime = math.max(0, (1 / instance.TickPerSecond) - elapsed)
            task.wait(waitTime)
        end
    end

end

function Update:StopTicker()
    if Update.Ticker.Connection ~= nil then
        Update.Ticker.Connection:Disconnect()
    end
    Update.Ticker = nil
    
end

return Update