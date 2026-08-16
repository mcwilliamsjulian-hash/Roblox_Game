--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerRole = require(ReplicatedStorage.Shared.Enums.PlayerRole)

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "GameHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "StatusPanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.fromScale(0.5, 0.025)
panel.Size = UDim2.fromOffset(440, 112)
panel.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 210, 80)
stroke.Thickness = 2
stroke.Transparency = 0.25
stroke.Parent = panel

local roleLabel = Instance.new("TextLabel")
roleLabel.BackgroundTransparency = 1
roleLabel.Position = UDim2.fromOffset(12, 8)
roleLabel.Size = UDim2.new(1, -24, 0, 34)
roleLabel.Font = Enum.Font.GothamBold
roleLabel.TextSize = 24
roleLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
roleLabel.Parent = panel

local stateLabel = Instance.new("TextLabel")
stateLabel.BackgroundTransparency = 1
stateLabel.Position = UDim2.fromOffset(12, 44)
stateLabel.Size = UDim2.new(1, -24, 0, 26)
stateLabel.Font = Enum.Font.GothamMedium
stateLabel.TextSize = 18
stateLabel.TextColor3 = Color3.fromRGB(205, 208, 220)
stateLabel.Parent = panel

local objectiveLabel = Instance.new("TextLabel")
objectiveLabel.BackgroundTransparency = 1
objectiveLabel.Position = UDim2.fromOffset(12, 73)
objectiveLabel.Size = UDim2.new(1, -24, 0, 28)
objectiveLabel.Font = Enum.Font.Gotham
objectiveLabel.TextSize = 15
objectiveLabel.TextWrapped = true
objectiveLabel.TextColor3 = Color3.fromRGB(175, 180, 195)
objectiveLabel.Parent = panel

local function refresh()
	local role = player:GetAttribute("Role") or PlayerRole.None
	local state = workspace:GetAttribute("RoundState") or "Loading"
	local remaining = workspace:GetAttribute("TimeRemaining") or 0
	local message = workspace:GetAttribute("RoundMessage") or ""

	if role == PlayerRole.King then
		roleLabel.Text = "♛ YOU ARE THE KING"
		roleLabel.TextColor3 = Color3.fromRGB(255, 210, 70)
		objectiveLabel.Text = "Survive the uprising. Your Royal Bodyguards will defend you."
	elseif role == PlayerRole.Peasant then
		roleLabel.Text = "⚔ YOU ARE A PEASANT"
		roleLabel.TextColor3 = Color3.fromRGB(215, 220, 230)
		objectiveLabel.Text = "Work together to overthrow the King before time expires."
	else
		roleLabel.Text = "CROWNFALL"
		roleLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
		objectiveLabel.Text = message
	end
	stateLabel.Text = string.format("%s  •  %02d:%02d", state, math.floor(remaining / 60), remaining % 60)
	if state == "Ending" then
		objectiveLabel.Text = message
	end
end

for _, attribute in { "RoundState", "TimeRemaining", "RoundMessage" } do
	workspace:GetAttributeChangedSignal(attribute):Connect(refresh)
end
player:GetAttributeChangedSignal("Role"):Connect(refresh)
player:GetAttributeChangedSignal("Eliminated"):Connect(refresh)
refresh()
