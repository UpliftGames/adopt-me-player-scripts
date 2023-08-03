--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
	local cameraModule = PlayerModule:WaitForChild("CameraModule")
    local vehicleModule = cameraModule:WaitForChild("VehicleCamera")
	local vehicleCamera = require(vehicleModule)
    local VehicleCameraCore = require(vehicleModule:WaitForChild("VehicleCameraCore"))
    local VehicleCameraConfig = require(vehicleModule:WaitForChild("VehicleCameraConfig"))
    local CameraUtils = require(cameraModule:WaitForChild("CameraUtils"))

    local Spring = CameraUtils.Spring

    local EPSILON = 1e-3
    local YAW_DEFAULT = math.rad(0)

    function vehicleCamera:Reset()
		self.vehicleCameraCore = VehicleCameraCore.new(self:GetSubjectCFrame())
        self.pitchSpring = Spring.new(0, -math.rad(VehicleCameraConfig.pitchBaseAngle))
        self.yawSpring = Spring.new(0, YAW_DEFAULT)
        self.lastPanTick = 0
        
        local camera = workspace.CurrentCamera
        local cameraSubject = camera and camera.CameraSubject
        
        assert(camera)
        assert(cameraSubject)
        assert(cameraSubject:IsA("VehicleSeat"))
        
        -- GetConnectedParts is not coming back with the list we expect, so do this instead
        local assemblyParts = {}
        local parentModel = cameraSubject.Parent
        for _, part in parentModel:GetDescendants() do
            if part:IsA("BasePart") then
                table.insert(assemblyParts, part)
            end
        end
        local assemblyPosition, assemblyRadius = CameraUtils.getLooseBoundingSphere(assemblyParts)
        
        assemblyRadius = math.max(assemblyRadius, EPSILON)
        
        self.assemblyRadius = assemblyRadius
        self.assemblyOffset = cameraSubject.CFrame:Inverse()*assemblyPosition -- seat-space offset of the assembly bounding sphere center
        
        self:_StepInitialZoom()
	end
end

return module