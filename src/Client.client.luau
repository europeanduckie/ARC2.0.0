-- # Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- # Dependencies

local Core = ReplicatedStorage:FindFirstChild("Core")
local Framework = require(Core:FindFirstChild("Framework"))
local Modules = StarterPlayer.StarterPlayerScripts:FindFirstChild("Modules")
local Shared = Core:FindFirstChild("Shared")
local Components = StarterPlayer.StarterPlayerScripts:FindFirstChild("Components")
-- # Core

local MemUsage = collectgarbage("count")

local Client = Framework.Run()
Client:RequirePackages(Shared.SharedPackages)
Client:RequireComponents(Components)
Client:RequireModules(Shared)
Client:RequireModules(Modules)
Client:Init()
Client:Start()

Client:Print(string.format("Memory Used %s (KB)", MemUsage))
Client:Print("Report any bugs you find to the developer!")

local Camera = workspace.CurrentCamera
Camera.FieldOfView = 65