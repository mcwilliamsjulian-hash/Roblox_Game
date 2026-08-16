--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

function Remotes.getFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild("GameRemotes")
	if folder then
		return folder :: Folder
	end

	if not game:GetService("RunService"):IsServer() then
		return ReplicatedStorage:WaitForChild("GameRemotes") :: Folder
	end

	folder = Instance.new("Folder")
	folder.Name = "GameRemotes"
	folder.Parent = ReplicatedStorage
	return folder :: Folder
end

function Remotes.getEvent(name: string): RemoteEvent
	local folder = Remotes.getFolder()
	local event = folder:FindFirstChild(name)
	if event then
		return event :: RemoteEvent
	end

	if not game:GetService("RunService"):IsServer() then
		return folder:WaitForChild(name) :: RemoteEvent
	end

	event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = folder
	return event :: RemoteEvent
end

return table.freeze(Remotes)
