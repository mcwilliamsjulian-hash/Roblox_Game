--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local BodyguardConfig = require(ReplicatedStorage.Shared.Config.BodyguardConfig)
local BodyguardBuilder = require(script.Parent.Parent.Bodyguards.BodyguardBuilder)
local BodyguardController = require(script.Parent.Parent.Bodyguards.BodyguardController)

local BodyguardService = {}
local controllers: { BodyguardController.Controller } = {}

function BodyguardService.spawn(king: Player)
	BodyguardService.clear()
	local character = king.Character
	local kingRoot = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not kingRoot then
		return
	end

	for index = 1, BodyguardConfig.Count do
		local guard = BodyguardBuilder.create(BodyguardConfig.MaxHealth, BodyguardConfig.WalkSpeed)
		CollectionService:AddTag(guard, "RoyalBodyguard")
		local angle = (index - 1) / BodyguardConfig.Count * math.pi * 2
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * BodyguardConfig.FollowRadius
		guard:PivotTo(CFrame.new(kingRoot.Position + offset))
		guard.Parent = workspace
		for _, descendant in guard:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant:SetNetworkOwner(nil)
			end
		end
		local controller = BodyguardController.new(guard, king)
		table.insert(controllers, controller)
		controller:start()
	end
end

function BodyguardService.clear()
	for _, controller in controllers do
		controller:destroy()
	end
	table.clear(controllers)
end

return BodyguardService
