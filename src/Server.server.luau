-- # Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- # Dependencies

local Core = ReplicatedStorage:FindFirstChild("Core")
local Framework = require(Core:FindFirstChild("Framework"))
local Modules = ServerScriptService:FindFirstChild("Modules")
local Shared = Core:FindFirstChild("Shared")

-- # Core

local MemUsage = collectgarbage("count")

local Server = Framework.Run()
Server:RequirePackages(Shared.SharedPackages)
Server:RequireModules(Shared)
Server:RequireModules(Modules)
Server:Init()
Server:Start()

Server:Print(string.format("Memory Used %s (KB)", MemUsage))