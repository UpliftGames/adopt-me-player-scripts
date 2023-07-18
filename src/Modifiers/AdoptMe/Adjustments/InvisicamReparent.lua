--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
    local invisicam = require(PlayerModule:WaitForChild("CameraModule"):WaitForChild("Invisicam"))

    function invisicam:OnCameraSubjectChanged(cameraSubject)
        if cameraSubject:IsA("Humanoid") then
            self:Cleanup()
            self:CharacterAdded(cameraSubject.Parent, game.Players.LocalPlayer)
        end
    end
end

return module