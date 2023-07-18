--!nonstrict

local module = {}

module.priority = 3

function module.apply(PlayerModule: ModuleScript)
	local vehicleCameraModule = PlayerModule:WaitForChild("CameraModule"):WaitForChild("VehicleCamera")
	
	local vehicleCamera = require(vehicleCameraModule)
	local vehicleCameraConfig = require(vehicleCameraModule:WaitForChild("VehicleCameraConfig"))

	local defaultAutocorrectDelay = vehicleCameraConfig.autocorrectDelay
	local vehicleCameraUpdate = vehicleCamera.Update

	function vehicleCamera:Update(...)
		local camera = workspace.CurrentCamera
		local cameraSubject = camera and camera.CameraSubject

		local vehicleFollowCameraOverride do
			local valueObject = cameraSubject and cameraSubject:IsA('VehicleSeat') and cameraSubject:FindFirstChild('VehicleFollowCameraOverride')
			if valueObject then
				vehicleFollowCameraOverride = valueObject.Value
			else
				vehicleFollowCameraOverride = false
			end
		end

		if vehicleFollowCameraOverride then
			vehicleCameraConfig.autocorrectDelay = math.huge
		else
			vehicleCameraConfig.autocorrectDelay = defaultAutocorrectDelay
		end

		return vehicleCameraUpdate(self, ...)
	end

end

return module