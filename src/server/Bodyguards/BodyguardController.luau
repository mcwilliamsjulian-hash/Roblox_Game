--!strict

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BodyguardConfig = require(ReplicatedStorage.Shared.Config.BodyguardConfig)
local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local BodyguardTargeting = require(script.Parent.BodyguardTargeting)
local CombatService = require(script.Parent.Parent.Services.CombatService)

local BodyguardController = {}
BodyguardController.__index = BodyguardController

export type Controller = typeof(setmetatable({
	guard = nil :: Model?,
	king = nil :: Player?,
	running = false,
	target = nil :: Player?,
	lastPathAt = 0,
	waypoints = {} :: { PathWaypoint },
	waypointIndex = 1,
}, BodyguardController))

function BodyguardController.new(guard: Model, king: Player): Controller
	return setmetatable({
		guard = guard,
		king = king,
		running = false,
		target = nil,
		lastPathAt = 0,
		waypoints = {},
		waypointIndex = 1,
	}, BodyguardController)
end

local function getRoot(model: Model?): BasePart?
	return if model then model:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end

function BodyguardController:_setDestination(destination: Vector3)
	local guard = self.guard :: Model
	local humanoid = guard:FindFirstChildOfClass("Humanoid")
	local root = getRoot(guard)
	if not humanoid or not root then
		return
	end

	local now = workspace:GetServerTimeNow()
	if now - self.lastPathAt >= BodyguardConfig.PathRefreshInterval then
		self.lastPathAt = now
		local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
		local ok = pcall(function()
			path:ComputeAsync(root.Position, destination)
		end)
		if ok and path.Status == Enum.PathStatus.Success then
			self.waypoints = path:GetWaypoints()
			self.waypointIndex = math.min(2, #self.waypoints)
		end
	end

	local waypoint = self.waypoints[self.waypointIndex]
	if waypoint then
		if (root.Position - waypoint.Position).Magnitude <= BodyguardConfig.WaypointReachedDistance then
			self.waypointIndex += 1
			waypoint = self.waypoints[self.waypointIndex]
		end
		if waypoint then
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end
			humanoid:MoveTo(waypoint.Position)
			return
		end
	end
	humanoid:MoveTo(destination)
end

function BodyguardController:_step()
	local guard = self.guard :: Model
	local king = self.king :: Player
	local guardRoot = getRoot(guard)
	local kingRoot = getRoot(king.Character)
	local guardHumanoid = guard:FindFirstChildOfClass("Humanoid")
	if not guardRoot or not kingRoot or not guardHumanoid or guardHumanoid.Health <= 0 then
		self.running = false
		return
	end

	local kingDistance = (guardRoot.Position - kingRoot.Position).Magnitude
	if kingDistance > BodyguardConfig.LeashRadius then
		self.target = nil
	elseif self.target then
		local targetRoot = getRoot(self.target.Character)
		local targetHumanoid = self.target.Character and self.target.Character:FindFirstChildOfClass("Humanoid")
		if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 or self.target:GetAttribute("Eliminated") == true then
			self.target = nil
		end
	end

	if not self.target and kingDistance <= BodyguardConfig.LeashRadius then
		self.target = BodyguardTargeting.nearest(guardRoot.Position, BodyguardConfig.DetectionRadius)
	end

	if self.target then
		local targetRoot = getRoot(self.target.Character)
		if targetRoot then
			CombatService.guardAttack(guard, self.target, CombatConfig.Bodyguard)
			self:_setDestination(targetRoot.Position)
		end
	elseif kingDistance > BodyguardConfig.FollowRadius then
		self:_setDestination(kingRoot.Position)
	else
		guardHumanoid:Move(Vector3.zero)
	end
end

function BodyguardController:start()
	if self.running then
		return
	end
	self.running = true
	task.spawn(function()
		while self.running and self.guard and self.guard.Parent do
			self:_step()
			task.wait(BodyguardConfig.ThinkInterval)
		end
	end)
end

function BodyguardController:destroy()
	self.running = false
	if self.guard then
		self.guard:Destroy()
		self.guard = nil
	end
end

return BodyguardController
