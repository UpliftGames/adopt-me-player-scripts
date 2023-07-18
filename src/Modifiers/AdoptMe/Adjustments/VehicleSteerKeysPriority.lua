--!nonstrict

local module = {}

module.priority = 1

function module.apply(PlayerModule: ModuleScript)
    local vehicleController = require(PlayerModule:WaitForChild("ControlModule"):WaitForChild("VehicleController"))

    -- Set this to true if you want to instead use the triggers for the throttle
    local useTriggersForThrottle = true

    local ContextActionService = game:GetService("ContextActionService")

    function vehicleController:BindContextActions()
        if useTriggersForThrottle then
            ContextActionService:BindActionAtPriority("throttleAccel", (function(actionName, inputState, inputObject)
                self:OnThrottleAccel(actionName, inputState, inputObject)
                return Enum.ContextActionResult.Pass
            end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonR2)
            ContextActionService:BindActionAtPriority("throttleDeccel", (function(actionName, inputState, inputObject)
                self:OnThrottleDeccel(actionName, inputState, inputObject)
                return Enum.ContextActionResult.Pass
            end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonL2)
        end
        -- Camera rebinds arrows keys so this needs a higher priority than the camera script
        ContextActionService:BindActionAtPriority("arrowSteerRight", (function(actionName, inputState, inputObject)
            self:OnSteerRight(actionName, inputState, inputObject)
            return Enum.ContextActionResult.Pass
        end), false, self.CONTROL_ACTION_PRIORITY + 1, Enum.KeyCode.Right)
    
        -- Camera rebinds arrows keys so this needs a higher priority than the camera script
        ContextActionService:BindActionAtPriority("arrowSteerLeft", (function(actionName, inputState, inputObject)
            self:OnSteerLeft(actionName, inputState, inputObject)
            return Enum.ContextActionResult.Pass
        end), false, self.CONTROL_ACTION_PRIORITY + 1, Enum.KeyCode.Left)
    end
end

return module