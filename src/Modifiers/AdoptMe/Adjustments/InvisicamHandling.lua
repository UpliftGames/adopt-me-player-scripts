--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
    local myPlayer = game:GetService("Players").LocalPlayer
    local cameraModule = PlayerModule:WaitForChild("CameraModule")
    local cameraObject = require(cameraModule)
    local invisicam = require(cameraModule:WaitForChild("Invisicam"))

    myPlayer.ChildAdded:connect(function(obj)
		if obj.Name ~= "invisicam" then return end
		
		cameraObject:ActivateOcclusionModule(Enum.DevCameraOcclusionMode.Invisicam)
	end)
	myPlayer.ChildRemoved:connect(function(obj)
		if obj.Name ~= "invisicam" then return end
		
		cameraObject:ActivateOcclusionModule(Enum.DevCameraOcclusionMode.Zoom)
	end)

    local oldUpdate = cameraObject.Update

    function cameraObject:Update(dt)
        oldUpdate(self,dt)

        if not self.activeCameraController and self.activeOcclusionModule then
            self.activeOcclusionModule:Update(dt, game.Workspace.CurrentCamera.CFrame, game.Workspace.CurrentCamera.Focus)
        end
    end

    function invisicam:OnCameraSubjectChanged(cameraSubject)
        if cameraSubject:IsA("Humanoid") then
            self:Cleanup()
            self:CharacterAdded(cameraSubject.Parent, game.Players.LocalPlayer)
        end
    end
end

return module