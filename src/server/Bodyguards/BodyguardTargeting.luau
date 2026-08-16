--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)

local BodyguardTargeting = {}

function BodyguardTargeting.nearest(origin: Vector3, maxDistance: number): Player?
	local nearestPlayer = nil
	local nearestDistance = maxDistance
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("Role") == PlayerRole.Peasant and player:GetAttribute("Eliminated") ~= true then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if humanoid and humanoid.Health > 0 and root then
				local distance = (root.Position - origin).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					nearestPlayer = player
				end
			end
		end
	end
	return nearestPlayer
end

return table.freeze(BodyguardTargeting)
