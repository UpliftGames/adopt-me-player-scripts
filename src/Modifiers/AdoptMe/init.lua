--!strict

local function searchAndReplace(parent: Instance, replacements: {Instance})
	for _, replacement in replacements do
		local found = parent:FindFirstChild(replacement.Name)
		if found then
			searchAndReplace(found, replacement:GetChildren())

			if not replacement:IsA("Folder") then
				local copy = replacement:Clone()
				copy:ClearAllChildren()
				copy.Parent = found.Parent

				for _, child in found:GetChildren() do
					child.Parent = copy
				end

				found:Destroy()
			end
		end
	end
end

return function(PlayerModule: ModuleScript)
	local replacements = script:WaitForChild("Replacements")
	searchAndReplace(PlayerModule, replacements:GetChildren())

	local adjustmentsByPriority = {}
	local adjustmentsFolder = script:WaitForChild("Fixes")
	
	for _, adjustmentModule in adjustmentsFolder:GetChildren() do
		local result = require(adjustmentModule)
		table.insert(adjustmentsByPriority, result)
	end

	table.sort(adjustmentsByPriority, function(a, b)
		return a.priority < b.priority
	end)

	for _, fix in adjustmentsByPriority do
		fix.apply(PlayerModule)
	end
end