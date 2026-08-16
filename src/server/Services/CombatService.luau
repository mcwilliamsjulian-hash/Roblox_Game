--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoleService = require(script.Parent.RoleService)
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)

export type WeaponDefinition = { Damage: number, Range: number, Cooldown: number }

local CombatService = {}
local roundActive = false
local lastAttacks: { [Instance]: number } = {}

function CombatService.setRoundActive(active: boolean)
	roundActive = active
	if not active then
		table.clear(lastAttacks)
	end
end

local function livingHumanoid(model: Model?): Humanoid?
	if not model then
		return nil
	end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return humanoid
	end
	return nil
end

local function inRange(origin: Model, target: Model, range: number): boolean
	local originPart = origin.PrimaryPart or origin:FindFirstChild("HumanoidRootPart") :: BasePart?
	local targetPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") :: BasePart?
	return originPart ~= nil and targetPart ~= nil and (originPart.Position - targetPart.Position).Magnitude <= range
end

local function cooldownReady(key: Instance, cooldown: number): boolean
	local now = workspace:GetServerTimeNow()
	local previous = lastAttacks[key] or 0
	if now - previous < cooldown then
		return false
	end
	lastAttacks[key] = now
	return true
end

function CombatService.playerAttack(player: Player, tool: Tool, definition: WeaponDefinition)
	if not roundActive or tool.Parent ~= player.Character or player:GetAttribute("Eliminated") == true then
		return
	end
	local character = player.Character
	if not livingHumanoid(character) or not cooldownReady(tool, definition.Cooldown) then
		return
	end

	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local parts = workspace:GetPartBoundsInBox(root.CFrame * CFrame.new(0, 0, -definition.Range / 2), Vector3.new(6, 6, definition.Range), params)
	local checked: { [Model]: boolean } = {}
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not checked[model] then
			checked[model] = true
			local targetPlayer = Players:GetPlayerFromCharacter(model)
			local humanoid = livingHumanoid(model)
			if targetPlayer and humanoid and RoleService.isHostile(player, targetPlayer) and inRange(character :: Model, model, definition.Range) then
				humanoid:TakeDamage(definition.Damage)
				return
			end
		end
	end
end

function CombatService.guardAttack(guard: Model, target: Player, definition: WeaponDefinition)
	if not roundActive or target:GetAttribute("Role") ~= PlayerRole.Peasant or target:GetAttribute("Eliminated") == true then
		return
	end
	local targetCharacter = target.Character
	local humanoid = livingHumanoid(targetCharacter)
	if humanoid and livingHumanoid(guard) and inRange(guard, targetCharacter :: Model, definition.Range) and cooldownReady(guard, definition.Cooldown) then
		humanoid:TakeDamage(definition.Damage)
	end
end

return CombatService
