--!strict

local PhysicsService = game:GetService("PhysicsService")

local BodyguardBuilder = {}

local function makePart(name: string, size: Vector3, color: Color3, parent: Model): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.CanCollide = name == "HumanoidRootPart"
	part.Parent = parent
	return part
end

function BodyguardBuilder.create(maxHealth: number, walkSpeed: number): Model
	local model = Instance.new("Model")
	model.Name = "Royal Bodyguard"
	model:SetAttribute("IsBodyguard", true)

	local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(35, 35, 45), model)
	root.Transparency = 1
	root.CFrame = CFrame.new(0, 5, 0)
	local torso = makePart("Torso", Vector3.new(2.4, 3, 1.2), Color3.fromRGB(45, 55, 90), model)
	torso.CFrame = root.CFrame
	local head = makePart("Head", Vector3.new(2, 1, 1), Color3.fromRGB(215, 175, 140), model)
	head.CFrame = root.CFrame * CFrame.new(0, 2, 0)

	for _, part in { torso, head } do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = root
		part.Massless = true
		part.CanCollide = false
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = maxHealth
	humanoid.Health = maxHealth
	humanoid.WalkSpeed = walkSpeed
	humanoid.DisplayName = "Royal Bodyguard"
	humanoid.Parent = model
	model.PrimaryPart = root

	pcall(function()
		PhysicsService:RegisterCollisionGroup("Bodyguards")
	end)
	PhysicsService:CollisionGroupSetCollidable("Bodyguards", "Bodyguards", false)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Bodyguards"
		end
	end
	return model
end

return table.freeze(BodyguardBuilder)
