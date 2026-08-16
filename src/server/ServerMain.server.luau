--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)
local RoundService = require(script.Services.RoundService)

Players.CharacterAutoLoads = false

local function initializePlayer(player: Player)
	player:SetAttribute("Role", PlayerRole.None)
	player:SetAttribute("Eliminated", false)
	player:LoadCharacter()
end

Players.PlayerAdded:Connect(initializePlayer)
for _, player in Players:GetPlayers() do
	initializePlayer(player)
end

RoundService.start()
