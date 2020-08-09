local view = {}
view.__index = view

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local offsets = setmetatable({}, {
	__call = function(_, mode, Chrt)
		if mode:lower() == "front" then
			return CFrame.new((Chrt.CFrame * CFrame.new(0, 0, -10 )).Position, Chrt.Position)
		elseif mode:lower() == "back" then
			return CFrame.new((Chrt.CFrame * CFrame.new(0, 0, 10 )).Position, Chrt.Position)
		elseif mode:lower() == "freecam" then
			return Chrt.CFrame * player.Character.HumanoidRootPart.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame)
		end
	end
})

local rendered_bodyparts = {
    --R6 Characters
	["Torso"] = true;
	["Head"] =  true;
	["HumanoidRootPart"] = true;
	["Left Arm"] = true;
	["Left Leg"] = true;
	["Right Arm"] = true;
	["Right Leg"] = true;
    --R15 Characters
	["LeftFoot"] = true;
	["LeftHand"] = true;
	["LeftLowerArm"] = true;
	["LeftLowerLeg"] = true;
	["LeftUpperArm"] = true;
	["LeftUpperLeg"] = true;
	["LowerTorso"] = true;
	["RightFoot"] = true;
	["RightHand"] = true;
	["RightLowerArm"] = true;
	["RightLowerLeg"] = true;
	["RightUpperArm"] = true;
	["RightUpperLeg"] = true;
	["UpperTorso"] = true;
}

--These are children instances that will not be cloned.
local trash = {
	["ModuleScript"] = true;
	["Script"] = true;
	["LocalScript"] = true;
	["Frame"] = true;
	["ScreenGui"] = true;
	["TextButton"] = true;
	["TextLabel"] = true;
	["TextBox"] = true;
	["ScrollingFrame"] = true;
	["ViewportFrame"] = true;
	["ClickDetector"] = true;
	["Animation"] = true;
	["ImageLabel"] = true;
	["ImageButton"] = true;
	["Camera"] = true;
	["BillboardGui"] = true;
	["SurfaceGui"] = true;
	["Decal"] = true;
}

local function camera_render(camera, cloned_char, mode)
	return RunService.RenderStepped:Connect(function(step)
		camera.CFrame = offsets(mode, cloned_char["HumanoidRootPart"])
	end)
end

--Remove unneccessary instances
local function clean_up(object)
	for _, v in ipairs(object:GetDescendants()) do
		if trash[v.ClassName] then
			v:Destroy()
		end
	end
end

local function view_ui(viewport_frame, data)
	if data:IsA("ViewportFrame") then
		viewport_frame.Visible = true
		data.Visible = true
	else
		viewport_frame.BackgroundTransparency = 1
		viewport_frame.Position = data.Position
		viewport_frame.Size = data.Size
		viewport_frame.Parent.Enabled = true
		viewport_frame.Visible = true
	end
end

function view.new(data, char)
	if not data:IsA("ViewportFrame") then --If not passed already-made viewport frame, checks if you instead passed the Position and Size parameters in the data list
		assert(data.Size and typeof(data.Size) == "UDim2")
		assert(data.Position and typeof(data.Position) == "UDim2")
	end
	local self = setmetatable({}, view)
	if  data:IsA("ViewportFrame") then
		self._viewport = data
	else
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ViewCharacter.fr"
		screenGui.Parent = player:WaitForChild("PlayerGui")
		self._viewport = Instance.new("ViewportFrame", screenGui)
	end
	self._character = char
	self._data = data
	self._clonedchar = {}
	self._updatechar = {}
	self._events = {}
	self._accessorypool = {}
	self._vehicle = {}
	return self
end

local function disconnectAllEvents(tabl)
	for _, v in ipairs(tabl) do
		v:Disconnect()
	end
	pcall(function()
		tabl["Cam"]:Disconnect()
	end)
	
	return {}
end

function view:Enable(Mode)
	self._viewport:ClearAllChildren()
	self._events = disconnectAllEvents(self._events)
	self._clonedchar = {}
	self._updatechar = {}
	if self._camera then self._camera:Destroy() end
	self._camera = Instance.new("Camera", self._viewport)
	self:InitAddition()
	self:TrackChanges()
	view_ui(self._viewport, self._data)
	self._viewport.CurrentCamera = self._camera
	Mode = Mode or "Front"
	self._events["Cam"] = camera_render(self._camera, self._clonedchar, self._previousmode or Mode)
	self._previousmode = Mode
	local added
	added = self._character.ChildAdded:Connect(function(child)
		self._clonedchar[child.Name] = child
		local clone = child:Clone()
		clean_up(clone)
		clone.Parent = self._clonedchar["HumanoidRootPart"].Parent
		local event
		event = RunService.Heartbeat:Connect(function()
			if child then
				for _, v in ipairs(clone:GetChildren()) do
					if v:IsA("BasePart") then
						pcall(function()
							v.CFrame = child[v.Name].CFrame
						end)
					end
				end
			else
				event:Disconnect()
			end
		end)
		self._events[child] = event
	end)
	local removed
	removed = self._character.ChildRemoved:Connect(function(child)
		if self._events[child] then self._events[child]:Disconnect(); self._events[child] = nil end
		self._clonedchar[child.Name] = nil
		local model = self._clonedchar["HumanoidRootPart"].Parent
		local child_viewport = model:FindFirstChild(child.Name)
		if child_viewport then
			child_viewport:Destroy()
		end
	end)
	
	self._character:WaitForChild("Humanoid").Died:Connect(function()
		self:Freeze()
		removed:Disconnect()
		added:Disconnect()
	end)
	
    --Minor support for vehicles
	self._character:WaitForChild("Humanoid").StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Seated then
			local ray = Ray.new(self._character.HumanoidRootPart.Position, -self._character.HumanoidRootPart.CFrame.UpVector * 2)
			local part = workspace:FindPartOnRay(ray, self._character)
			if part then
				local parent = part:FindFirstAncestorWhichIsA("Model")
				if parent then
					self._vehicle = parent:GetChildren()
					self:LoadOnToView(self._vehicle)
				end
			end
		elseif old == Enum.HumanoidStateType.Seated then
			self:UnLoadFromView(self._vehicle)
			self._vehicle = {}
		end
	end)
end

function view:SwitchMode(mode)
	self._events["Cam"]:Disconnect()
	self._events["Cam"] = camera_render(self._camera, self._clonedchar, mode)
end

function view:Disable()
	self._viewport:ClearAllChildren()
	disconnectAllEvents(self._events)
end

function view:Freeze()
	disconnectAllEvents(self._events)
end

function view:Unfreeze()
	coroutine.wrap(function()
		self:Enable(self._previousmode)
	end)()
end

function view:InitAddition() -- Internal use
	self._character.Archivable=true
	local clonedModel = Instance.new("Model")
	for _, v in ipairs(self._character:GetChildren()) do
		if v:IsA("Accessory") then 
			repeat wait() until v:FindFirstChild("Handle") ~= nil	
		 end
		if (v.Archivable == false) then
			v.Archivable = true
			local clone = v:Clone()
			clean_up(clone)
			clone.Parent = clonedModel
			self._clonedchar[v.Name] = clone
			v.Archivable = false
		else
			local clone = v:Clone()
			clean_up(clone)
			self._clonedchar[v.Name] = clone
			clone.Parent = clonedModel
		end
    	end
    	clonedModel.Parent = self._viewport
end

function view:TrackChanges() --Internal use
	for _, v in ipairs(self._character:GetChildren()) do
		if (v:IsA("BasePart") and rendered_bodyparts[v.Name]) or v:IsA("Tool") or v:IsA("Humanoid") then
			table.insert(self._updatechar, v)
			print("added", v)
		end
	end
	
	if self._character:FindFirstChildWhichIsA("Accessory") then
		self:ReloadAccessories()
		print("Loading accessories!")
	else
		print("No accessories to load!")
	end
	for i = 1, #self._updatechar do
		local object = self._updatechar[i]
		if object:IsA("BasePart") then
			local event
			event = RunService.Heartbeat:Connect(function()
				if object then
					self:Update(object, "CFrame")
				else
					event:Disconnect()
				end
			end)
			table.insert(self._events, event)
		elseif object:IsA("Humanoid") then
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Climbing,	false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			self._clonedchar[object.Name]:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
			self._clonedchar[object.Name].HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			self._clonedchar[object.Name].DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		elseif object:IsA("Accessory") or object:IsA("Tool") then
			local event
			if object:IsA("Accessory") then
				event = RunService.Heartbeat:Connect(function()
					if object then
						self:Update(object, "CFrame")
					else
						event:Disconnect()
					end
				end)
			elseif object:IsA("Tool") then
				event = RunService.Heartbeat:Connect(function()
					if object then
						self:Update(object, "CFrame")
					else
						event:Disconnect()
					end
				end)
			end
			table.insert(self._events, event)
		end
	end
end

function view:Update(object, property) --Internal use
	pcall(function()
		if object:IsA("Accessory") or object:IsA("Tool") then
			if object:IsA("Tool") then print("updating wtf") end
			self._clonedchar[object.Name].Handle[property] = object.Handle[property]
		else
			self._clonedchar[object.Name][property] = object[property]
		end
	end)
end

function view:UpdateCustomLoaded(OriginalObject, ClonedObject, Property)
	pcall(function()
		ClonedObject[Property] = OriginalObject[Property]
	end)
end

function view:ReloadAccessories()
	local accessories = {}
	for _, v in ipairs(self._character:GetChildren()) do
		if v:IsA("Accessory") then
			table.insert(accessories, v)
			table.insert(self._updatechar, v)
		end
	end
	return #accessories
end

function view:LoadOnToView(tabl)
	for _, v in ipairs(tabl) do
		if self._viewport:FindFirstChild(v.Name) and self._viewport:FindFirstChildOfClass(v.ClassName) and (self._viewport[v.Name]:IsA("BasePart") or self._viewport[v.Name]:IsA("Decal")) then
			if self._viewport[v.Name].Transparency == 1 then
				self._viewport[v.Name].Transparency = 0
			end
			continue
		end
		if v:IsA("BasePart") and not (v.Parent:IsA("Model") and v.Parent.PrimaryPart ~= nil and v.Parent.PrimaryPart == v) and v.Transparency == 1 then continue end
		if v:IsA("Light") then continue end
        coroutine.wrap(function()
            local decal = v:FindFirstChildWhichIsA("Decal", true)
            if decal then
                decal:Destroy()
            end
        end)
		local clone = v:Clone()
		clean_up(clone)
		clone.Parent = self._viewport
		local event
		event = RunService.Heartbeat:Connect(function()
			if v then
				self:UpdateCustomLoaded(v, clone,"CFrame")
			else
				clone:Destroy()
				event:Disconnect()
			end
		end)
	end
end

function view:UnLoadFromView(tabl)
	for _, v in ipairs(tabl) do
		if self._viewport:FindFirstChild(v.Name) and self._viewport:FindFirstChildOfClass(v.ClassName) and (self._viewport[v.Name]:IsA("BasePart") or self._viewport[v.Name]:IsA("Decal")) then
			if self._viewport[v.Name].Transparency == 0 then
				self._viewport[v.Name]["Transparency"] = 1
			end
		end
		if v:IsA("Light") then continue end
        coroutine.wrap(function()
            local decal =  v:FindFirstChildWhichIsA("Decal", true)
            if decal then
                decal.Transparency = 1
            end
        end)()
	end
end

function view:Destroy()
	self._viewport = nil
	self._data = nil
	self._clonedchar = nil
	self._updatechar = nil
	for _, v in pairs(self._events) do
		v:Disconnect()
	end
	self._events = nil
	self._camera = nil
	self._previousmode = nil
end

return view