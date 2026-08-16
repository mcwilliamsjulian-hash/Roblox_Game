--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)

local RoleService = {}

function RoleService.assign(players: { Player }, previousKing: Player?): Player
	assert(#players > 0, "Cannot assign roles without players")

	local candidates = table.clone(players)
	if previousKing and #candidates > 1 then
		local index = table.find(candidates, previousKing)
		if index then
			table.remove(candidates, index)
		end
	end

	local king = candidates[Random.new():NextInteger(1, #candidates)]
	for _, player in players do
		player:SetAttribute("Role", if player == king then PlayerRole.King else PlayerRole.Peasant)
		player:SetAttribute("Eliminated", false)
	end
	return king
end

function RoleService.clear(players: { Player })
	for _, player in players do
		player:SetAttribute("Role", PlayerRole.None)
		player:SetAttribute("Eliminated", false)
	end
end

function RoleService.isHostile(attacker: Player, target: Player): boolean
	local attackerRole = attacker:GetAttribute("Role")
	local targetRole = target:GetAttribute("Role")
	return (attackerRole == PlayerRole.King and targetRole == PlayerRole.Peasant)
		or (attackerRole == PlayerRole.Peasant and targetRole == PlayerRole.King)
end

return table.freeze(RoleService)
