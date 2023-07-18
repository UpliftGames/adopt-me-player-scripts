--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
	local myPlayer = game:GetService("Players").LocalPlayer
	local controlObject = require(PlayerModule:WaitForChild("ControlModule"))

	local moveDisabled = false

	local setControlEnabled = Instance.new("BindableEvent")
	setControlEnabled.Name = "SetControlEnabled"
	setControlEnabled.Parent = myPlayer
	setControlEnabled.Event:connect(function(enabled)
		moveDisabled = not enabled
	end)

	local function fissy_move(...)
		if not moveDisabled then
			myPlayer.Move(...)
		end
	end

	controlObject.moveFunction = fissy_move
end

return module