local RunService = game:GetService("RunService")

local Framework = {}
Framework.__index = Framework

export type FrameworkDataTable = typeof(setmetatable(
    {} :: {
        SubName: string,
        Module: any,
    },
    Framework
))

export type Framework = typeof(setmetatable(
    {} :: {
        DEBUG: boolean,

        Enviornment: "CLIENT" | "SERVER",
        Loaded: boolean,

        Components: { [string]: FrameworkDataTable },
        Packages: { [string]: FrameworkDataTable },
        Modules: { [string]: FrameworkDataTable },
    },
    Framework
))

local _Instance: Framework? = nil

function Framework:Print(...: any): ()
    print(string.format("[✅] %s :", self.Enviornment), ...)
end

function Framework:Error(...: any): ()
    print(string.format("[🟥] %s :", self.Enviornment), ...)
end

function Framework.Run(): Framework
   if _Instance then
        if _Instance.DEBUG then
            _Instance:Print("Framework instance already exists, returning existing instance")
        end
        return _Instance
    end

    local self = {
        DEBUG = false,
        Enviornment = RunService:IsClient() and "CLIENT" or "SERVER",
        Loaded = false,
        
        Components = {},
        Packages = {},
        Modules = {},
    }

    setmetatable(self, Framework)

    _Instance = self

    self:Print("Framework Instance launched")

    return self
end

function Framework:GetModule(x: string): ()
	if self.Modules[x] then
		return self.Modules[x].Module
	else
		self:Error(string.format("%s is not apart of Modules.", x))
		error('Error')
	end
end

function Framework:GetPackage(x: string): ()
	if self.Packages[x] then
		return self.Packages[x].Module
	else
		self:Error(string.format("%s is not apart of Packages.", x))
        error('Error')
	end
end

function Framework:GetComponent(x: string): ()
	if self.Components[x] then
		return self.Components[x].Module
	else
		self:Error(string.format("%s is not apart of Components.", x))
		error('Error')
	end
end

function Framework:RequirePackages(Directory: Instance): ()
    local _parent = Directory.Parent

    for _, x in Directory:GetChildren() do
        if x:IsA("ModuleScript") then
            local subName = x:GetFullName():sub(#_parent:GetFullName() + 2)

            self.Packages[x.Name] = {
                SubName = subName,
                Module = require(x),
            }

            self:Print(string.format("Required %s", subName))
        end
    end

    return self
end

function Framework:RequireComponents(Directory: Instance): ()
    if self.Enviornment ~= "CLIENT" then
        print("RequireComponents can only be called in a client environment")
        return
    end

    local _parent = Directory.Parent

    for _, x in Directory:GetChildren() do
        if x:IsA("ModuleScript") then
            local subName = x:GetFullName():sub(#_parent:GetFullName() + 2)

            self.Components[x.Name] = {
                SubName = subName,
                Module = require(x),
            }

            self:Print(string.format("Required %s", subName))
        end
    end

    return self
end

function Framework:RequireModules(Directory: Instance): ()
    local _parent = Directory.Parent

    for _, x in Directory:GetChildren() do
        if x:IsA("ModuleScript") then
            local subName = x:GetFullName():sub(#_parent:GetFullName() + 2)

            self.Modules[x.Name] = {
                SubName = subName,
                Module = require(x),
            }

            self:Print(string.format("Required %s", subName))
        end
    end

    return self
end

function Framework:Init(): ()
    local MainTimer = os.clock()
    for _, x in pairs(self.Modules) do
        local SubTimer = os.clock()

        if type(x.Module) == "table" and type(x.Module.Init) == "function" then
            x.Module:Init()
        end

        self:Print(string.format("Initialized %s in [%.3f ms]", x.SubName, (os.clock() - SubTimer) * 1000))
        SubTimer = nil
    end

    self:Print(string.format("Initialized all modules in [%.3f ms]", (os.clock() - MainTimer) * 1000))
    MainTimer = nil
end

function Framework:Start(): ()
    local MainTimer = os.clock()
    for _, x in pairs(self.Modules) do
        local SubTimer = os.clock()

        if type(x.Module) == "table" and type(x.Module.Start) == "function" then
            x.Module:Start()
        end

        self:Print(string.format("Started %s in [%.3f ms]", x.SubName, (os.clock() - SubTimer) * 1000))
        SubTimer = nil
    end

    self:Print(string.format("Started all modules in [%.3f ms]", (os.clock() - MainTimer) * 1000))
    MainTimer = nil

    self.Loaded = true
end

function Framework:Stop(): ()
    if not self.Loaded then
        self:Error("Framework is not fully loaded yet, continuing anyways")

        _Instance = nil
        table.clear(self)
        return
    end

    self:Error("Framework Stopping")

    _Instance = nil
    table.clear(self)
end

return Framework