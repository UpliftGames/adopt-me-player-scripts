--!nonstrict

local module = {}

module.priority = 4

function module.apply(PlayerModule: ModuleScript)
	local controlObject = require(PlayerModule:WaitForChild("ControlModule"))

	function controlObject:OnCharacterAdded(char)
		self.humanoid = char:FindFirstChildOfClass("Humanoid")
		while not self.humanoid do
			char.ChildAdded:wait()
			self.humanoid = char:FindFirstChildOfClass("Humanoid")
		end
	
		self:UpdateTouchGuiVisibility()
	
		if self.humanoidSeatedConn then
			self.humanoidSeatedConn:Disconnect()
			self.humanoidSeatedConn = nil
		end
		
		-- Fix for vehicle seats sometimes not controlling at all.
		-- See https://devforum.roblox.com/t/vehicleseat-unreliable-sometimes-doesnt-work/428992/18
		local ticket = 0
		self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(active, currentSeatPart)
			ticket = ticket + 1
			local thisTicket = ticket
			if active and not currentSeatPart then
				repeat
					task.wait()
				until self.humanoid.SeatPart
				if ticket ~= thisTicket then return end
			end
			self:OnHumanoidSeated(active, self.humanoid.SeatPart)
		end)
	end
end

return module