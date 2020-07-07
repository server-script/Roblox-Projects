local shader = {};

local function createPartWeld(part0, part1) --void
    local mainPart = (part0.Name ~= "shader.part" and part0) or part1;
    local weld = Instance.new("Weld");
    weld.Name = "shader.weld";
    weld.Parent = mainPart;
    weld.Part0 = part0;
    weld.Part1 = part1;
end

local function constructShaderBasedOnPartInfo(info)
    local part = Instance.new("Part");
    part.Name = "shader.part";
    part.Size = info.Size;
    part.CFrame = info.CFrame;
    part.BrickColor3 = BrickColor3.new("Red");
    part.CanCollide = false;
    part.Anchored = false;
    createPartWeld(part, info.originalPart)
end

local function getBasePartInfo(basePart)
    local properties = {};
    properties.originalPart = basePart;
    properties.CFrame = basePart.CFrame;
    properties.Size = basePart.Size;
    properties.Color = basePart.BrickColor3;
    return properties;
end

local function applyModelShader(model)
    for _, v in ipairs(model) do
        if v:IsA("BasePart") then
            local props = getBasePartInfo(v);
            constructShaderBasedOnPartInfo(props);
        end
    end
end

function shader.applyCelShader(group)
    applyModelShader(group);
end

return shader;
