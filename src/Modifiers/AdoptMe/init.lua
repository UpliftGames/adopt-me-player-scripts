local ReplaceFiles = script:WaitForChild("ReplaceFiles")

local filesToReplace = {}
local function findFilesToReplace(parent, leaves)
    for _, child in ipairs(parent:GetChildren()) do
        if #child:GetChildren() == 0 then
            table.insert(leaves, child)
        else
            findFilesToReplace(child, leaves)
        end
    end
end
findFilesToReplace(ReplaceFiles, filesToReplace)

return function(PlayerModule)
	for _, file in ipairs(filesToReplace) do
		local target = PlayerModule.CameraModule:FindFirstChild(file.Name, true) or PlayerModule.ControlModule:FindFirstChild(file.Name, true)
		if target then
			local targetParent = target.Parent
			target:Destroy()
			file:Clone().Parent = targetParent
		end
	end
end