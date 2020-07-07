local shader = {};

shader.Exceptions = {"HumanoidRootPart"};

local function removeUnnecessaryBits(model)
	for _, v in ipairs(model:GetDescendants()) do
		if not v:IsA("BasePart") and not v:IsA("SpecialMesh") then
			v:Destroy();
		end
	end
end

local function createPartWeld(part0, part1) --part0 is the shader part and part1 is the bodypart ur shading over
	local weld = Instance.new("Weld");
	weld.Name = "shader.weld";
	weld.Parent = part0;
	weld.Part0 = part0;
	weld.Part1 = part1;
end

local function constructShaderBasedOnBasePartInfo(info, storage, brickColor)
	brickColor = brickColor or BrickColor.new("Really black");
	local part = (info.originalPart:IsA("Part") and Instance.new("Part")) or (info.originalPart:IsA("Part") == false and info.originalPart:Clone());
	part.Name = "shader.part";
	part.Size = info.Size + Vector3.new(.05, .05, .05);
	if info.originalPart.Name:lower() == "head" then
		part.Name = "shader.head";
		local mesh = Instance.new("SpecialMesh");
		mesh.MeshType = Enum.MeshType.Head;
		mesh.Parent = part;
	elseif info.originalPart.Name:lower() == "torso" then
		part.Name = "shader.torso";
		local mesh = Instance.new("SpecialMesh");
		mesh.MeshType = Enum.MeshType.Torso;
		mesh.Parent = part;
	end
	part.CFrame = info.CFrame;
	part.BrickColor = brickColor;
	part.CanCollide = false;
	part.Anchored = false;  
	part.Material = Enum.Material.ForceField
	removeUnnecessaryBits(part);
	part.Parent = storage;
	createPartWeld(part, info.originalPart);
end

local function getBasePartInfo(basePart)
	local properties = {};
	properties.originalPart = basePart;
	properties.CFrame = basePart.CFrame;
	properties.Size = basePart.Size;
	return properties;
end

local function applyModelShader(model, storage, brickColor)
	for _, v in ipairs(model:GetChildren()) do
		if v:IsA("BasePart") then
				for _, e in ipairs(shader.Exceptions) do
					if v.Name ~= e then
						local props = getBasePartInfo(v);
						constructShaderBasedOnBasePartInfo(props, storage, brickColor);

					end
				end
		end
	end
end

function shader.applyCelShader(groupedModel, brickColor)
	local shaderStorage = groupedModel:FindFirstChild(groupedModel.Name) or Instance.new("Model", groupedModel);
	shaderStorage.Name = groupedModel.Name;
	applyModelShader(groupedModel, shaderStorage, brickColor);

	for _, v in ipairs(groupedModel:GetChildren()) do
		if v:IsA("Model") or v:IsA("Folder") then
			applyModelShader(groupedModel, shaderStorage, brickColor);
		end
	end
	
end

function shader.removeCelShader(groupedModel)
	local storage = groupedModel:FindFirstChild(groupedModel.Name)
	if storage then
		for _, v in ipairs(storage:GetChildren()) do
			v:Destroy();
		end
	else
		warn(groupedModel.ClassName.." "..groupedModel.Name.." has no shaders!");
	end
end

return shader;
