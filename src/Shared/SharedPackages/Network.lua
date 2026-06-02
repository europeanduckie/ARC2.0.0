-- # Core

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:FindFirstChild("Core")

local FrameworkModule = require(Core:FindFirstChild("Framework"))
local Framework = FrameworkModule.Run()

local Network = {}
Network.__index = Network

export type Network = typeof(setmetatable(
    {} :: {
        Remote: "RemoteEvent" | "RemoteFunction",
    },
    Network
))

function Network.new(RemoteName: string, Remote: "RemoteEvent" | "RemoteFunction"): Network
    local existingInstance = Core.__REMOTES[(Remote == "RemoteEvent") and "EVENT" or "FUNCTION"]:FindFirstChild(RemoteName)
    if existingInstance then
        local self = setmetatable({}, Network)
        self.Remote = existingInstance
        return self
    end

    local self = setmetatable({}, Network)

    if Framework.Enviornment == "SERVER" then
        self.Remote = Instance.new(Remote)
        self.Remote.Name = RemoteName
        self.Remote.Parent = Core.__REMOTES[(Remote == "RemoteEvent") and "EVENT" or "FUNCTION"]
    else
        print(string.format("[%s]: Remote: %s couldn't be created on Client.", Framework.Enviornment, RemoteName))
    end

    return self
end

function Network:Fire(...): ()
    if not self.Remote:IsA("RemoteEvent") then
        error(string.format("[%s]: Attempted to fire Event %s, but it is not a RemoteEvent", Framework.Enviornment, self.Remote.Name))
    end

    if Framework.Enviornment == "SERVER" then
        self.Remote:FireClient(...)
    else
        self.Remote:FireServer(...)
    end

    return self
end

function Network:Fired(...): ()
    if not self.Remote:IsA("RemoteEvent") then
        error(string.format("[%s]: Attempted to connect to Event %s, but it is not a RemoteEvent", Framework.Enviornment, self.Remote.Name))
    end

    if Framework.Enviornment == "SERVER" then
        self.Remote.OnServerEvent:Connect(...)
    else
        self.Remote.OnClientEvent:Connect(...)
    end

    return self
end

function Network:Invoke(...): ()
    if not self.Remote:IsA("RemoteFunction") then
        error(string.format("[%s]: Attempted to invoke Function %s, but it is not a RemoteFunction", Framework.Enviornment, self.Remote.Name))
    end

    if Framework.Enviornment == "SERVER" then
        return self.Remote:InvokeClient(...)
    else
        return self.Remote:InvokeServer(...)
    end
end

function Network:Invoked(...): ()
    if not self.Remote:IsA("RemoteFunction") then
        error(string.format("[%s]: Attempted to connect to Function %s, but it is not a RemoteFunction", Framework.Enviornment, self.Remote.Name))
    end

    if Framework.Enviornment == "SERVER" then
        self.Remote.OnServerInvoke = ...
    else
        self.Remote.OnClientInvoke = ...
    end
end

return Network