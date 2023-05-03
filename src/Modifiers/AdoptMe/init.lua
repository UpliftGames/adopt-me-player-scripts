local ReplaceFiles = script:WaitForChild("ReplaceFiles")
local NewPopper = ReplaceFiles.Popper

-- iterate replacefiles children

return function(PlayerModule)
	--replace all listed files

	PlayerModule.CameraModule.ZoomController.Popper:Destroy()
	NewPopper:Clone().Parent  = PlayerModule.CameraModule.ZoomController
end