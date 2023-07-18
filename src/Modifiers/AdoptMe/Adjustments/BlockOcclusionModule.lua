--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
    local myPlayer = game:GetService("Players").LocalPlayer
    local cameraModule = PlayerModule:WaitForChild("CameraModule")
    local cameraObject = require(cameraModule)
    local CameraInput = require(cameraModule:WaitForChild("CameraInput"))

    myPlayer.ChildAdded:connect(function(obj)
		if obj.Name ~= "invisicam" then return end
		
		cameraObject:ActivateOcclusionModule(Enum.DevCameraOcclusionMode.Invisicam)
	end)
	myPlayer.ChildRemoved:connect(function(obj)
		if obj.Name ~= "invisicam" then return end
		
		cameraObject:ActivateOcclusionModule(Enum.DevCameraOcclusionMode.Zoom)
	end)

    function cameraObject:Update(dt)
        if self.activeCameraController then
            self.activeCameraController:UpdateMouseBehavior()
    
            local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)
    
            if self.activeOcclusionModule then
                newCameraCFrame, newCameraFocus = self.activeOcclusionModule:Update(dt, newCameraCFrame, newCameraFocus)
            end
    
            -- Here is where the new CFrame and Focus are set for this render frame
            local currentCamera = game.Workspace.CurrentCamera :: Camera
            currentCamera.CFrame = newCameraCFrame
            currentCamera.Focus = newCameraFocus
    
            -- Update to character local transparency as needed based on camera-to-subject distance
            if self.activeTransparencyController then
                self.activeTransparencyController:Update(dt)
            else
                if self.activeOcclusionModule then
                    self.activeOcclusionModule:Update(dt, game.Workspace.CurrentCamera.CFrame, game.Workspace.CurrentCamera.Focus)
            
                end
            end

            if CameraInput.getInputEnabled() then
                CameraInput.resetInputForFrameEnd()
            end
        end
    end
end

return module