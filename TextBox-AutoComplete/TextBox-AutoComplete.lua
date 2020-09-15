--This is the official Debug Version of the AutComplete module made by fredrick254, code
local AutoComplete = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local function concatTable(source)
	if typeof(source[1]):lower() == "string" then
		local finalstring = ""
		for _, sourceString in ipairs(source) do
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			print(sourceString)
			finalstring = finalstring.." "..sourceString
		end
		return finalstring
	else
		local final = ""
		for _, object in pairs(source) do
			final = final.." "..object.Name
		end
		return final
	end
end

local function performCheck(source, search, func)
	search = search:match("^%s*(.-)%s*$")
	search = search:gsub(" ", "-")
	print("Searching for ", search)
	if #search < 1 then return nil end
	
	local resultFound = false
	for match in string.gmatch(source, "%S+") do
		if match:sub(1, #search):lower() == search:lower() then
			match = match:gsub("-", " ")
			coroutine.wrap(func)(match)
		end
	end
	return resultFound
end

local function mainDetectionFunction(enum, box, source)
	local event0
	local preEvent0
	local preEvent1
	local frame = box:WaitForChild("Clippable")
	local suggestions = {}
	
	if typeof(source) == "string" and source:sub(1, #"builtin"):lower() == "builtin" then
		local directory = source:sub(#"builtin/"+1, #source):lower()
		source = ""
		for _, child in ipairs(Players:GetPlayers()) do
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source .. " " .. sourceString
		end
		if directory == "players" then
			preEvent0 = Players.PlayerAdded:Connect(function(player)
				source = source.." "..player.Name
			end)
			preEvent1 = Players.PlayerRemoving:Connect(function(player)
				source = source:gsub("%s*"..player.Name.."%s*", " ")
			end)
		end
	end
	
	if typeof(source) == "Instance" then
		local children = source:GetChildren()
		local instance = source
		source = ""
		for _, child in ipairs(children) do
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source .. " " .. sourceString
		end
		
		preEvent0 = instance.ChildAdded:Connect(function(child)
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source.." "..child.Name
		end)
		preEvent1 = instance.ChildRemoved:Connect(function(child)
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source:gsub("%s*"..sourceString.."%s*", " ")
		end)
	end
	
	local function showSuggestion(name)
		local shadow_new = frame.Template:Clone()
		shadow_new.Text = name
		shadow_new.Name = "Suggestion"
		shadow_new.Visible = true
		shadow_new.BackgroundTransparency = 0
		shadow_new.Parent = frame
		table.insert(suggestions, shadow_new)
	end
	
	local function clearSuggestions()
		for _, v in ipairs(suggestions) do
			v:Destroy()
		end
	end
	
	event0 = frame and UserInputService.InputEnded:Connect(function(input, gp)
		if input.UserInputType == enum and gp then
			clearSuggestions()
			performCheck(source, box.Text, showSuggestion)
		end
	end)
	
	
	UserInputService.TextBoxFocusReleased:Wait()
	if event0 then
		event0:Disconnect()
		if preEvent0 and preEvent1 then
			preEvent0:Disconnect()
			preEvent1:Disconnect()
		end
	end
end

local function dropDownAutoFill(textBoxOriginal, source)
	if typeof(source) == "table" then
		source = concatTable(source)
	end
	
	local frame = Instance.new("Frame")
	frame.Name = "Clippable"
	frame.Position = UDim2.fromScale(0, 1)
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = textBoxOriginal
	
	local uiList = Instance.new("UIListLayout")
	uiList.Parent = frame
	uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local template = Instance.new("TextButton")
	template.Size = UDim2.fromScale(1, 1)
	template.Name = "Template"
	template.Visible = false
	template.BackgroundTransparency = 1
	template.Parent = frame
	
	local function clear(button)
		for _, v in ipairs(button.Parent:GetChildren()) do
			if v:IsA("TextButton") and v.Name:lower() ~= "template" then
				v:Destroy()
			end
		end
	end
	
	frame.ChildAdded:Connect(function(child)
		if child:IsA("TextButton") then
			child.MouseButton1Click:Connect(function()
				if child.Visible then
					textBoxOriginal.Text = child.Text
					clear(child)
				end
			end)
		end
	end)
	
	UserInputService.TextBoxFocused:Connect(function(textBox)
		if textBox == textBoxOriginal then
			if UserInputService.KeyboardEnabled then
				mainDetectionFunction(Enum.UserInputType.Keyboard, textBoxOriginal, source)
			elseif UserInputService.GamepadEnabled then
				mainDetectionFunction(Enum.UserInputType.Gamepad1 , textBoxOriginal, source)
			else
				mainDetectionFunction(Enum.UserInputType.Touch, textBoxOriginal, source)
			end
		end
	end)
end

local function performCheck2(source, search)
	search = search:match("^%s*(.-)%s*$")
	local result = source:match(" "..search.." ") or source:match(search.."%S*") or source:match("%S*"..search)
	if result then
		result = result:gsub("-", " ")
		result = result:match("^%s*(.-)%s*$")
	end
	return result
end

local function autoFillMain(enum, box, source)
	local preEvent0
	local preEvent1
	
	if typeof(source) == "string" and source:sub(1, #"builtin"):lower() == "builtin" then
		local directory = source:sub(#"builtin/"+1, #source):lower()
		source = ""
		for _, child in ipairs(Players:GetPlayers()) do
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source .. " " .. sourceString
		end
		if directory == "players" then
			preEvent0 = Players.PlayerAdded:Connect(function(player)
				source = source.." "..player.Name
			end)
			preEvent1 = Players.PlayerRemoving:Connect(function(player)
				source = source:gsub("%s*"..player.Name.."%s*", " ")
			end)
		end
	end
	
	if typeof(source) == "Instance" then
		local children = source:GetChildren()
		local instance = source
		source = ""
		for _, child in ipairs(children) do
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source .. " " .. sourceString
		end
		
		preEvent0 = instance.ChildAdded:Connect(function(child)
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source.." "..child.Name
		end)
		preEvent1 = instance.ChildRemoved:Connect(function(child)
			local sourceString = child.Name
			sourceString = sourceString:match("^%s*(.-)%s*$")
			sourceString = string.gsub(sourceString, " ", "-")
			source = source:gsub("%s*"..sourceString.."%s*", " ")
		end)
	end
	
	local shadow = box.Parent
	local event0
	event0 = UserInputService.InputEnded:Connect(function(input, gp)
		if input.UserInputType == enum and gp then
			local result = performCheck2(source, box.Text)
			shadow.Text = result or ""
		end
	end)
	UserInputService.TextBoxFocusReleased:Wait()
	event0:Disconnect()
	preEvent1:Disconnect()
	preEvent0:Disconnect()
end

local function autoFill(textBoxOriginal, source)
	if typeof(source) == "table" then
		source = concatTable(source)
	end
	textBoxOriginal.BackgroundTransparency = 0.5
	textBoxOriginal.TextXAlignment = Enum.TextXAlignment.Left
	local duplicateFrame = Instance.new("TextLabel")
	duplicateFrame.Position = textBoxOriginal.Position
	duplicateFrame.Size = textBoxOriginal.Size
	duplicateFrame.TextSize = textBoxOriginal.TextSize
	duplicateFrame.Font = textBoxOriginal.Font
	duplicateFrame.TextColor3 = Color3.fromRGB(66, 66, 52)
	duplicateFrame.TextScaled = textBoxOriginal.TextScaled
	duplicateFrame.TextWrapped = textBoxOriginal.TextWrapped
	duplicateFrame.TextXAlignment = Enum.TextXAlignment.Left
	duplicateFrame.Parent = textBoxOriginal.Parent
	textBoxOriginal.Size = UDim2.fromScale(1, 1)
	textBoxOriginal.Position = UDim2.fromScale(0, 0)
	textBoxOriginal.Parent = duplicateFrame
	
	textBoxOriginal.Focused:Connect(function()
		if UserInputService.KeyboardEnabled then
			autoFillMain(Enum.UserInputType.Keyboard, textBoxOriginal, source)
		elseif UserInputService.GamepadEnabled then
			autoFillMain(Enum.UserInputType.Gamepad1 , textBoxOriginal, source)
		else
			autoFillMain(Enum.UserInputType.Touch, textBoxOriginal, source)
		end
	end)
end

function AutoComplete.Init(textBoxOriginal, source, typeOfAutoComplete)
	assert(textBoxOriginal:IsA("TextBox"), "Type error: Textbox expected, got"..textBoxOriginal.ClassName)
	textBoxOriginal.ClipsDescendants = false
	if typeOfAutoComplete:lower() == "dropdown" then
		dropDownAutoFill(textBoxOriginal, source)
	elseif typeOfAutoComplete:lower() == "autofill" then
		autoFill(textBoxOriginal, source)
	end
end

return AutoComplete