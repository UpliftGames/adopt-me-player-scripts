--[[
	TransparencyController - Manages transparency of player character at close camera-to-subject distances
	2018 Camera Update - AllYourBlox
--]]

--[[
	Modified for Adopt Me! 
		- TeardownTransparency(), SetupTransparency(), Update(): handling ImageLabel since it has a different transparency property name
		- Update(): handling transparency scaling for babies team (team code below in this section) 
]]--

local team = "N/A"
spawn(function()
	local load = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
	local ClientData = load("ClientData")
	
	while true do
		team = ClientData.get("team")
		wait(.3)
	end
end)

--------------

local MAX_TWEEN_RATE = 2.8 -- per second

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ The Module ]]--
local TransparencyController = {}
TransparencyController.__index = TransparencyController

function TransparencyController.new()
	local self = setmetatable({}, TransparencyController)

	self.lastUpdate = tick()
	self.transparencyDirty = false
	self.enabled = false
	self.lastTransparency = nil

	self.descendantAddedConn, self.descendantRemovingConn = nil, nil
	self.toolDescendantAddedConns = {}
	self.toolDescendantRemovingConns = {}
	self.cachedParts = {}

	return self
end


function TransparencyController:HasToolAncestor(object)
	if object.Parent == nil then return false end
	return object.Parent:IsA('Tool') or self:HasToolAncestor(object.Parent)
end

function TransparencyController:IsValidPartToModify(part)
	if part:IsA('BasePart') or part:IsA('Decal') or part:IsA('ImageLabel') then	
		return not self:HasToolAncestor(part)
	end
	return false
end

function TransparencyController:CachePartsRecursive(object)
	if object then
		if self:IsValidPartToModify(object) then
			self.cachedParts[object] = true
			self.transparencyDirty = true
		end
		for _, child in pairs(object:GetChildren()) do
			self:CachePartsRecursive(child)
		end
	end
end

function TransparencyController:TeardownTransparency()
	for child, _ in pairs(self.cachedParts) do
		if child:IsA("ImageLabel") then
			child.ImageTransparency = 0
		else
			child.LocalTransparencyModifier = 0
		end
	end
	self.cachedParts = {}
	self.transparencyDirty = true
	self.lastTransparency = nil

	if self.descendantAddedConn then
		self.descendantAddedConn:disconnect()
		self.descendantAddedConn = nil
	end
	if self.descendantRemovingConn then
		self.descendantRemovingConn:disconnect()
		self.descendantRemovingConn = nil
	end
	for object, conn in pairs(self.toolDescendantAddedConns) do
		conn:Disconnect()
		self.toolDescendantAddedConns[object] = nil
	end
	for object, conn in pairs(self.toolDescendantRemovingConns) do
		conn:Disconnect()
		self.toolDescendantRemovingConns[object] = nil
	end
end

function TransparencyController:SetupTransparency(character)
	self:TeardownTransparency()

	if self.descendantAddedConn then self.descendantAddedConn:disconnect() end
	self.descendantAddedConn = character.DescendantAdded:Connect(function(object)
		-- This is a part we want to invisify
		if self:IsValidPartToModify(object) then
			self.cachedParts[object] = true
			self.transparencyDirty = true
		-- There is now a tool under the character
		elseif object:IsA('Tool') then
			if self.toolDescendantAddedConns[object] then self.toolDescendantAddedConns[object]:Disconnect() end
			self.toolDescendantAddedConns[object] = object.DescendantAdded:Connect(function(toolChild)
				self.cachedParts[toolChild] = nil

				if toolChild:IsA("ImageLabel") then
					toolChild.ImageTransparency = 0
				elseif toolChild:IsA('BasePart') or toolChild:IsA('Decal') then
					toolChild.LocalTransparencyModifier = 0
				end
			end)
			if self.toolDescendantRemovingConns[object] then self.toolDescendantRemovingConns[object]:disconnect() end
			self.toolDescendantRemovingConns[object] = object.DescendantRemoving:Connect(function(formerToolChild)
				wait() -- wait for new parent
				if character and formerToolChild and formerToolChild:IsDescendantOf(character) then
					if self:IsValidPartToModify(formerToolChild) then
						self.cachedParts[formerToolChild] = true
						self.transparencyDirty = true
					end
				end
			end)
		end
	end)
	if self.descendantRemovingConn then self.descendantRemovingConn:disconnect() end
	self.descendantRemovingConn = character.DescendantRemoving:connect(function(object)
		if self.cachedParts[object] then
			self.cachedParts[object] = nil
			
			if object:IsA("ImageLabel") then
				object.ImageTransparency = 0
			else
				object.LocalTransparencyModifier = 0
			end
		end
	end)
	self:CachePartsRecursive(character)
end


function TransparencyController:Enable(enable)
	if self.enabled ~= enable then
		self.enabled = enable
		self:Update()
	end
end

function TransparencyController:SetSubject(subject)
	local character = nil
	if subject and subject:IsA("Humanoid") then
		character = subject.Parent
	end
	if subject and subject:IsA("VehicleSeat") and subject.Occupant then
		character = subject.Occupant.Parent
	end
	if character then
		self:SetupTransparency(character)
	else
		self:TeardownTransparency()
	end
end

function TransparencyController:Update()
	local instant = false
	local now = tick()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local transparency = 0
		if not self.enabled then
			instant = true
		else
			local distance = (currentCamera.Focus.p - currentCamera.CoordinateFrame.p).magnitude
			transparency = ((team == "Babies" and 3.5 or 7) - distance) / (team == "Babies" and 2.5 or 5)
			if transparency < 0.5 then
				transparency = 0
			end

			if self.lastTransparency then
				local deltaTransparency = transparency - self.lastTransparency

				-- Don't tween transparency if it is instant or your character was fully invisible last frame
				if not instant and transparency < 1 and self.lastTransparency < 0.95 then
					local maxDelta = MAX_TWEEN_RATE * (now - self.lastUpdate)
					deltaTransparency = math.clamp(deltaTransparency, -maxDelta, maxDelta)
				end
				transparency = self.lastTransparency + deltaTransparency
			else
				self.transparencyDirty = true
			end

			transparency = math.clamp(Util.Round(transparency, 2), 0, 1)
		end

		if self.transparencyDirty or self.lastTransparency ~= transparency then
			for child, _ in pairs(self.cachedParts) do
				if child:IsA("ImageLabel") then
					child.ImageTransparency = transparency
				else
					child.LocalTransparencyModifier = transparency
				end
			end
			self.transparencyDirty = false
			self.lastTransparency = transparency
		end
	end
	self.lastUpdate = now
end

return TransparencyController