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
	["BaseScript"] = true;
	["GuiBase"] = true;
	["GuiObject"] = true;
	["ClickDetector"] = true;
	["Animation"] = true;
	["Camera"] = true;
	["ValueBase"] = true;
	["Configuration"] = true;
}

local function rename_similars(model)
	for i, v in ipairs(model:GetChildren()) do
		local equivalent = model:FindFirstChild(v.Name)
		if equivalent and v ~= equivalent then
			print("Renamed!")
			model[v.Name].Name = v.Name..math.random(1, 100000000)..string.rep(math.random(1, 100), math.random(1, 5))
		end
	end
end

local function camera_render(camera, cloned_char, mode)
	return RunService.RenderStepped:Connect(function(step)
		camera.CFrame = offsets(mode, cloned_char["HumanoidRootPart"])
	end)
end

local function clean_up(object)
	for _, v in ipairs(object:GetDescendants()) do
		if v:IsA("BaseScript") or v:IsA("GuiObject") or v:IsA("GuiBase2d") or v:IsA("ParticleEmitter") or v:IsA("Camera") or v:IsA("ValueBase") or v:IsA("Camera") or v:IsA("Motor") or v:IsA("Weld") then
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
	wait(2) --Important for waiting for the character to load at least its body parts.
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
    self._backups = {}
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
    Mode = self._previousmode or Mode or "Front"
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

	self._events["Cam"] = camera_render(self._camera, self._clonedchar, Mode)
	self._previousmode = Mode

	local added
	added = self._character.ChildAdded:Connect(function(child)
		if not child:IsA("Accoutrement") then return end
		self._clonedchar[child.Name] = child
		local clone = child:Clone()
		clean_up(clone)
		clone.Parent = self._clonedchar["HumanoidRootPart"].Parent
		local event
		event = RunService.Heartbeat:Connect(function()
			if child then
				for _, v in ipairs(clone:GetChildren()) do
					if v:IsA("BasePart") then
							v.CFrame = child[v.Name].CFrame
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
    local died
	died = self._character:WaitForChild("Humanoid").Died:Connect(function()
		self:Freeze()
		removed:Disconnect()
		added:Disconnect()
	end)
	table.insert(self._events, died)

    --Minor support for vehicles
	self._character:WaitForChild("Humanoid").StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Seated then
			local ray = Ray.new(self._character.HumanoidRootPart.Position, -self._character.HumanoidRootPart.CFrame.UpVector * 2)
			local part = workspace:FindPartOnRay(ray, self._character)
			if part then
				local parent = part:FindFirstAncestorWhichIsA("Model", true);
				if parent then
					rename_similars(parent)
					self._vehicle = parent:GetChildren()
                    if not self._backups[parent.Parent.Name..parent.Name] then
                        self._backups[parent.Parent.Name..parent.Name] = parent
                    end
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
		local archivable = v.Archivable
		v.Archivable = true
		local clone = v:Clone()
		clean_up(clone)
		clone.Parent = clonedModel
		self._clonedchar[v.Name] = clone
		v.Archivable = archivable
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
		if object:IsA("BasePart") or object:IsA("UnionOperation") then
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
	if object:IsA("Humanoid") then return end
    if object:IsA("Accoutrement") then
        self._clonedchar[object.Name].Handle[property] = object.Handle[property]
    else
        self._clonedchar[object.Name][property] = object[property]
    end
end

function view:UpdateCustomLoaded(OriginalObject, ClonedObject, Property)
	if OriginalObject:IsA("BasePart") or OriginalObject:IsA("UnionOperation") then
		ClonedObject[Property] = OriginalObject[Property]
	end
end

function view:ReloadAccessories()
	local accessories = {}
    local char_children = self._character:GetChildren()
	for i = 1, #char_children do
		if char_children[i]:IsA("Accessory") then
			table.insert(accessories, char_children[i])
			table.insert(self._updatechar, char_children[i])
		end
	end
end

function view:LoadOnToView(tabl)
    local backed_up = self._backups[tabl[1].Parent.Parent.Name..tabl[1].Parent.Name]
    if typeof(backed_up) == "table" then
        for i = 1, #backed_up do
            if backed_up[i]:IsA("BasePart") or backed_up[i]:IsA("Decal") or backed_up[i]:IsA("UnionOperation") then
                local new_transparency = (backed_up[i].Transparency == 0 and 1) or 0
                backed_up[i].Transparency = new_transparency
            end 
        end
        return
    end
    self._backups[tabl[1].Parent.Parent.Name..tabl[1].Parent.Name] = {}
    coroutine.wrap(function()
        for i = 1, #tabl do
            for _, v in ipairs(tabl[i]:GetDescendants()) do
                if v:IsA("Model") then
                    v:Destroy()
                end
            end
        end
    end)()
	for i = 1, #tabl do
        if tabl[i]:IsA("Light") then continue end
        if (tabl[i]:IsA("BasePart") or tabl[i]:IsA("Decal") or tabl[i]:IsA("UnionOperation")) and tabl[i].Transparency == 1 then continue end
        --if tabl[i]:IsDescendantOf(self._viewport) and (tabl[i]:IsA("BasePart") or tabl[i]:IsA("UnionOperation") or tabl[i]:IsA("Decal")) then
			--if self._viewport[tabl[i].Name].Transparency == 1 then
			--	self._viewport[tabl[i].Name].Transparency = 0
			--end
		--	continue
		--end
		--if v:IsA("BasePart") and not (v.Parent:IsA("Model") and v.Parent.PrimaryPart ~= nil and v.Parent.PrimaryPart == v) and v.Transparency == 1 then continue end
		local clone = tabl[i]:Clone()
		clean_up(clone)
		clone.Parent = self._viewport
        
        table.insert(self._backups[tabl[1].Parent.Parent.Name..tabl[1].Parent.Name], clone)
		local event
        local object = tabl[i]
		event = RunService.Heartbeat:Connect(function()
			if object then
				self:UpdateCustomLoaded(tabl[i], clone,"CFrame")
			else
				clone:Destroy()
				event:Disconnect()
			end
		end)
        table.insert(self._events, event)
	end
end

function view:UnLoadFromView(tabl)
    local table_rel = self._backups[tabl[1].Parent.Parent.Name..tabl[1].Parent.Name]
    if typeof(table_rel == "table") then
        for i = 1, #table_rel do
            if table_rel[i]:IsA("BasePart") or table_rel[i]:IsA("UnionOperation") or table_rel[i]:IsA("Decal") then
                table_rel[i].Transparency = 1
            end
        end
        return
    end

	--for i = 1, #tabl do
   --     if tabl[i]:IsA("Light") then continue end
	--	if tabl[i]:IsDescendantOf(self._viewport) and (tabl[i]:IsA("BasePart") or tabl[i]:IsA("UnionOperation") or tabl[i]:IsA("Decal")) then
	--		if self._viewport[tabl[i].Name].Transparency == 0 then
--				self._viewport[tabl[i].Name].Transparency = 1
	--		end
	--	end
	--end
end

function view:Destroy()
    self:Disable()
	self._viewport = nil
	self._data = nil
	self._clonedchar = nil
	self._updatechar = nil
	self._events = nil
	self._camera = nil
	self._previousmode = nil
    self._vehicle = nil
    self._backups = nil
end

return view