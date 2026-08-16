--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BodyguardService = require(script.Parent.BodyguardService)
local CombatService = require(script.Parent.CombatService)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local LoadoutService = require(script.Parent.LoadoutService)
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)
local RoleService = require(script.Parent.RoleService)
local RoundState = require(ReplicatedStorage.Shared.Enums.RoundState)
local SpawnService = require(script.Parent.SpawnService)

local RoundService = {}
local previousKing: Player? = nil
local endingReason: string? = nil
local deathConnections: { RBXScriptConnection } = {}

local function setState(state: string, timeRemaining: number, message: string?)
	workspace:SetAttribute("RoundState", state)
	workspace:SetAttribute("TimeRemaining", timeRemaining)
	workspace:SetAttribute("RoundMessage", message or "")
end

local function countdown(state: string, duration: number): boolean
	for remaining = duration, 0, -1 do
		if #Players:GetPlayers() < GameConfig.MinimumPlayers then
			return false
		end
		setState(state, remaining)
		task.wait(1)
	end
	return true
end

local function disconnectDeaths()
	for _, connection in deathConnections do
		connection:Disconnect()
	end
	table.clear(deathConnections)
end

local function loadCharacters(players: { Player })
	for _, player in players do
		player:LoadCharacter()
	end
	for _, player in players do
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			player.CharacterAdded:Wait()
		end
	end
end

local function livingPeasantCount(): number
	local count = 0
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("Role") == PlayerRole.Peasant and player:GetAttribute("Eliminated") ~= true then
			count += 1
		end
	end
	return count
end

local function observeDeaths(players: { Player }, king: Player)
	for _, player in players do
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			table.insert(deathConnections, humanoid.Died:Connect(function()
				player:SetAttribute("Eliminated", true)
				if player == king then
					endingReason = "The Peasants defeated the King!"
				elseif livingPeasantCount() == 0 then
					endingReason = "The King defeated every Peasant!"
				end
			end))
		end
	end
end

local function runRound()
	local participants = Players:GetPlayers()
	endingReason = nil
	disconnectDeaths()
	loadCharacters(participants)

	local king = RoleService.assign(participants, previousKing)
	previousKing = king
	local peasants = {}
	for _, player in participants do
		if player ~= king then
			table.insert(peasants, player)
		end
	end
	SpawnService.place(king, peasants)
	for _, player in participants do
		LoadoutService.equip(player)
	end
	observeDeaths(participants, king)
	CombatService.setRoundActive(true)
	BodyguardService.spawn(king)

	for remaining = GameConfig.RoundDuration, 0, -1 do
		setState(RoundState.Active, remaining)
		if endingReason then
			break
		end
		if king.Parent ~= Players then
			endingReason = "The King fled. The Peasants win!"
			break
		end
		if livingPeasantCount() == 0 then
			endingReason = "The King defeated every Peasant!"
			break
		end
		task.wait(1)
	end
	endingReason = endingReason or "Time expired. The King survives!"

	CombatService.setRoundActive(false)
	BodyguardService.clear()
	disconnectDeaths()
	setState(RoundState.Ending, GameConfig.EndScreenDuration, endingReason)
	for _, player in Players:GetPlayers() do
		LoadoutService.clear(player)
	end
	task.wait(GameConfig.EndScreenDuration)
	RoleService.clear(Players:GetPlayers())
end

function RoundService.start()
	task.spawn(function()
		while true do
			while #Players:GetPlayers() < GameConfig.MinimumPlayers do
				setState(RoundState.Waiting, 0, string.format("Waiting for %d players", GameConfig.MinimumPlayers))
				task.wait(1)
			end
			if countdown(RoundState.Intermission, GameConfig.IntermissionDuration) then
				runRound()
			end
		end
	end)
end

return table.freeze(RoundService)
