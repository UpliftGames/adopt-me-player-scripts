--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
	local controlObject = require(PlayerModule:WaitForChild("ControlModule"))

	function controlObject:OnCharacterAdded(char)
		-- Code below is from the default implementation of OnCharacterAdded.
		self.humanoid = char:FindFirstChildOfClass("Humanoid")
		while not self.humanoid do
			char.ChildAdded:wait()
			self.humanoid = char:FindFirstChildOfClass("Humanoid")
		end

		if self.UpdateTouchGuiVisibility then
			self:UpdateTouchGuiVisibility()
		else
			if self.touchGui then
				self.touchGui.Enabled = true
			end
		end

		if self.humanoidSeatedConn then
			self.humanoidSeatedConn:Disconnect()
			self.humanoidSeatedConn = nil
		end

		-- Begin the code needed for the actual fix.
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
		-- End of the code needed for the fix.
	end
end

return module