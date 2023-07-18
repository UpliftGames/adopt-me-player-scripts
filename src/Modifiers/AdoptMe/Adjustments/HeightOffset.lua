--!nonstrict

local Players = game:GetService("Players")

local ZERO_VECTOR3 = Vector3.new(0, 0, 0)

local SEAT_OFFSET = Vector3.new(0, 5, 0)
local HEAD_OFFSET = Vector3.new(0, 1.5, 0)
local R15_HEAD_OFFSET = Vector3.new(0, 1.5, 0)
local R15_HEAD_OFFSET_NO_SCALING = Vector3.new(0, 2, 0)
local HUMANOID_ROOT_PART_SIZE = Vector3.new(2, 2, 1)

local module = {}

module.priority = 2

function module.apply(PlayerModule: ModuleScript)
	local baseCamera = require(PlayerModule:WaitForChild("CameraModule"):WaitForChild("BaseCamera"))

	function baseCamera:GetSubjectPosition()
		local result = self.lastSubjectPosition
		local camera = game.Workspace.CurrentCamera
		local cameraSubject = camera and camera.CameraSubject
	
		if cameraSubject then
			if cameraSubject:IsA("Humanoid") then
				local humanoid = cameraSubject
				local humanoidIsDead = humanoid:GetState() == Enum.HumanoidStateType.Dead
	
				local bodyPartToFollow = humanoid.RootPart
	
				-- If the humanoid is dead, prefer their head part as a follow target, if it exists
				if humanoidIsDead then
					if humanoid.Parent and humanoid.Parent:IsA("Model") then
						bodyPartToFollow = humanoid.Parent:FindFirstChild("Head") or bodyPartToFollow
					end
				end
	
				if bodyPartToFollow and bodyPartToFollow:IsA("BasePart") then
					local heightOffset
					if humanoid.RigType == Enum.HumanoidRigType.R15 then
						if humanoid.AutomaticScalingEnabled then
							heightOffset = R15_HEAD_OFFSET
							if bodyPartToFollow == humanoid.RootPart then
								local rootPartSizeOffset = (humanoid.RootPart.Size.Y/2) - (HUMANOID_ROOT_PART_SIZE.Y/2)
								heightOffset = heightOffset + Vector3.new(0, rootPartSizeOffset, 0)
							end
						else
							heightOffset = R15_HEAD_OFFSET_NO_SCALING
						end
					else
						heightOffset = HEAD_OFFSET
					end
	
					if humanoidIsDead then
						heightOffset = ZERO_VECTOR3
					end

					local character = Players.LocalPlayer.Character
					local myHumanoid = character and character:FindFirstChild("Humanoid")
					local bodyHeightScale = myHumanoid and myHumanoid:FindFirstChild("BodyHeightScale") and myHumanoid.BodyHeightScale.Value or 1

					heightOffset = heightOffset * bodyHeightScale
					result = bodyPartToFollow.CFrame.p + bodyPartToFollow.CFrame:vectorToWorldSpace(heightOffset + humanoid.CameraOffset)
				end
	
			elseif cameraSubject:IsA("VehicleSeat") then
				local offset = SEAT_OFFSET

				if cameraSubject:FindFirstChild("CameraOffset") then
					offset = cameraSubject.CameraOffset.Value
				end

				result = cameraSubject.CFrame.p + cameraSubject.CFrame:vectorToWorldSpace(offset)
			elseif cameraSubject:IsA("SkateboardPlatform") then
				result = cameraSubject.CFrame.p + SEAT_OFFSET
			elseif cameraSubject:IsA("BasePart") then
				result = cameraSubject.CFrame.p
			elseif cameraSubject:IsA("Model") then
				if cameraSubject.PrimaryPart then
					result = cameraSubject:GetPrimaryPartCFrame().p
				else
					result = cameraSubject:GetModelCFrame().p
				end
			end
		else
			-- cameraSubject is nil
			-- Note: Previous RootCamera did not have this else case and let self.lastSubject and self.lastSubjectPosition
			-- both get set to nil in the case of cameraSubject being nil. This function now exits here to preserve the
			-- last set valid values for these, as nil values are not handled cases
			return nil
		end
	
		self.lastSubject = cameraSubject
		self.lastSubjectPosition = result
	
		return result
	end
end

return module