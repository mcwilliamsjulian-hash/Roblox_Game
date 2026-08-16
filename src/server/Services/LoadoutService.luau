--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)
local CombatService = require(script.Parent.CombatService)
local SwordFactory = require(script.Parent.Parent.Tools.SwordFactory)

local LoadoutService = {}

local function removeRoundTools(player: Player)
	for _, container in { player.Backpack, player.Character } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute("RoundTool") == true then
					child:Destroy()
				end
			end
		end
	end
end

function LoadoutService.equip(player: Player)
	removeRoundTools(player)
	local role = player:GetAttribute("Role")
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local definition
	local tool
	if role == PlayerRole.King then
		definition = CombatConfig.KingSword
		tool = SwordFactory.create("Royal Sword", Color3.fromRGB(255, 200, 45), "KingSword")
		humanoid.MaxHealth = GameConfig.KingMaxHealth
	elseif role == PlayerRole.Peasant then
		definition = CombatConfig.PeasantSword
		tool = SwordFactory.create("Peasant Sword", Color3.fromRGB(175, 180, 190), "PeasantSword")
		humanoid.MaxHealth = GameConfig.PeasantMaxHealth
	else
		return
	end
	humanoid.Health = humanoid.MaxHealth
	tool:SetAttribute("RoundTool", true)
	tool.Activated:Connect(function()
		CombatService.playerAttack(player, tool, definition)
	end)
	tool.Parent = player.Backpack
end

function LoadoutService.clear(player: Player)
	removeRoundTools(player)
end

return table.freeze(LoadoutService)
