local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Spring = {}
Spring.__index = Spring
function Spring.new(initial)
	local self = setmetatable({}, Spring)
	self.Position = initial or Vector3.new(0,0,0)
	self.Target = initial or Vector3.new(0,0,0)
	self.Speed = 50
	self.Damper = 1
	self.Velocity = Vector3.new(0,0,0)
	return self
end

function Spring:Update(dt)
	local diff = self.Target - self.Position
	local accel = diff * self.Speed - self.Velocity * 2 * math.sqrt(self.Speed)
	self.Velocity = self.Velocity + accel * dt
	self.Position = self.Position + self.Velocity * dt
	return self.Position
end

local Settings = {
	SmoothCamera = true,
	BlurEnabled = true,
	Strength = 4,
	FirstPersonTransparent = true,
}

local SmoothCamera = {}
local CameraSpring = Spring.new(Vector3.new(0,0,0))
local Character, Root
local CurrentBlur = 0

local function Setup()
	Character = Player.Character or Player.CharacterAdded:Wait()
	Root = Character:WaitForChild("HumanoidRootPart")

	if Settings.BlurEnabled then
		if not Lighting:FindFirstChild("SmoothCameraMotionBlur") then
			local Blur = Instance.new("BlurEffect")
			Blur.Name = "SmoothCameraMotionBlur"
			Blur.Enabled = true
			Blur.Size = 0
			Blur.Parent = Lighting
		end
	end

	if Settings.FirstPersonTransparent then
		for _,v in ipairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				v.LocalTransparencyModifier = 0
			end
		end
	end
	CameraSpring.Position = Camera.CFrame.Position - Root.Position
	CameraSpring.Target = CameraSpring.Position
end

local function Run(dt)
	dt = math.min(dt, 1/60)

	local targetOffset = Camera.CFrame.Position - Root.Position
	CameraSpring.Target = targetOffset

	local oldPos = Camera.CFrame.Position
	local smoothedOffset = CameraSpring:Update(dt)
	Camera.CFrame = CFrame.new(Root.Position + smoothedOffset, Root.Position + smoothedOffset + Camera.CFrame.LookVector)

	if Settings.BlurEnabled then
		local Blur = Lighting:FindFirstChild("SmoothCameraMotionBlur")
		if Blur then
			local delta = (Camera.CFrame.Position - oldPos).Magnitude
			local targetSize = math.clamp(delta * 10, 0, Settings.Strength)
			CurrentBlur = CurrentBlur + (targetSize - CurrentBlur) * math.clamp(dt * 5, 0, 1)
			Blur.Size = CurrentBlur
		end
	end
end

function SmoothCamera.Init()
	Setup()
end

function SmoothCamera.Start()
	if not Settings.SmoothCamera then return end
	Player.CharacterAdded:Connect(Setup)
	RunService:BindToRenderStep("__SMOOTHCAMERA", Enum.RenderPriority.Camera.Value + 1, Run)
end

return SmoothCamera