--!strict

local SwordFactory = {}

function SwordFactory.create(name: string, color: Color3, definitionName: string): Tool
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("WeaponDefinition", definitionName)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.35, 4, 0.65)
	handle.Color = color
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local guard = Instance.new("Part")
	guard.Name = "Crossguard"
	guard.Size = Vector3.new(2.2, 0.25, 0.35)
	guard.Color = Color3.fromRGB(80, 55, 30)
	guard.Material = Enum.Material.Wood
	guard.CanCollide = false
	guard.Massless = true
	guard.CFrame = handle.CFrame * CFrame.new(0, -1.35, 0)
	guard.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = guard
	weld.Parent = handle
	return tool
end

return table.freeze(SwordFactory)
