--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local SpawnService = {}

local function pivotCharacter(player: Player, position: Vector3)
	local character = player.Character
	if character then
		character:PivotTo(CFrame.new(position))
	end
end

function SpawnService.place(king: Player, peasants: { Player })
	pivotCharacter(king, GameConfig.SpawnCenter + GameConfig.KingSpawnOffset)
	for index, player in peasants do
		local angle = (index - 1) / math.max(#peasants, 1) * math.pi * 2
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * GameConfig.PeasantSpawnRadius
		pivotCharacter(player, GameConfig.SpawnCenter + offset)
	end
end

return table.freeze(SpawnService)
