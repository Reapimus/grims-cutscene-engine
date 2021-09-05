local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")

local keyframeFolder, actionFolder = Instance.new("Folder"), Instance.new("Folder")
keyframeFolder.Name = "Keyframes"
actionFolder.Name = "Actions"
keyframeFolder.Parent = script.TemplateCutscene
actionFolder.Parent = script.TemplateCutscene

function getIndex(index)
	local valType = typeof(index)

	if valType ~= "Instance" and valType ~= "number" then
		return index
	elseif index == workspace.CurrentCamera then
		return "[workspace.CurrentCamera]"
	end

	if valType == "Instance" then
		return string.format("[%s]", string.gsub(index:GetFullName(), "Workspace", "workspace"))
	else
		return string.format("[%s]", index)
	end
end

function getValue(value)
	local valType = typeof(value)

	if valType == "Vector3" then
		return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z)
	elseif valType == "Vector2" then
		return string.format("Vector2.new(%s, %s)", value.X, value.Y)
	elseif valType == "Color3" then
		return string.format("Color3.fromRGB(%s, %s, %s)", math.floor(value.R*255), math.floor(value.G*255), math.floor(value.B*255))
	elseif valType == "Vector3int16" then
		return string.format("Vector3int16.new(%s, %s, %s)", value.X, value.Y, value.Z)
	elseif valType == "bool" or valType == "number" or valType == "EnumItem" then
		return tostring(value)
	elseif valType == "Rect" then
		return string.format("Rect.new(%s, %s, %s, %s)", value.Min.X, value.Max.X, value.Min.Y, value.Max.Y)
	elseif valType == "UDim" then
		return string.format("UDim.new(%s, %s)", value.Scale, value.Offset)
	elseif valType == "UDim2" then
		return string.format("UDim2.new(%s, %s, %s, %s)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
	elseif valType == "CFrame" then
		return string.format("CFrame.new(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", value:GetComponents())
	elseif valType == "Instance" then
		if value == workspace.CurrentCamera then
			return "workspace.CurrentCamera"
		else
			return string.gsub(value:GetFullName(), "Workspace", "workspace")
		end
	end

	return string.format("\"%s\"", value)
end

function tableToString(tab, indent)
	local indent = indent or 1
	local s = "{\n".. string.rep("	", indent)

	local total = 0
	for _, _ in pairs(tab) do
		total += 1
	end

	local count = 0
	for i, v in pairs(tab) do
		count += 1
		if typeof(v) == "table" then
			s ..= string.format("%s = %s;\n", getIndex(i), tableToString(v, indent + 1))..string.rep("	", count == total and indent - 1 or indent)
		else
			s ..= string.format("%s = %s;\n", getIndex(i), getValue(v))..string.rep("	", count == total and indent - 1 or indent)
		end
	end

	s = s.."}"
	return s
end

return function(name, cutsceneData)
	local folder = ReplicatedStorage:FindFirstChild("ExportedCutscenes")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "ExportedCutscenes"
		folder.Parent = ReplicatedStorage
	end

	local module = folder:FindFirstChild(name)
	if module then
		module.Actions:ClearAllChildren()
		module.Keyframes:ClearAllChildren()
	else
		module = script.TemplateCutscene:Clone()
		module.Name = name
		module.Parent = folder
	end

	for i, v in pairs(cutsceneData.Keyframes) do
		local subModule = Instance.new("ModuleScript")
		subModule.Name = i:GetFullName()
		subModule.Source = "return ".. tableToString(v)

		local tag = Instance.new("ObjectValue")
		tag.Name = i == workspace.CurrentCamera and "CameraInstance" or "Instance"
		tag.Value = i
		tag.Parent = subModule

		subModule.Parent = module.Keyframes
	end

	for i, v in pairs(cutsceneData.Actions) do
		local subModule = Instance.new("ModuleScript")
		subModule.Name = i
		subModule.Source = "return ".. tableToString(v)
		subModule.Parent = module.Actions
	end

	Selection:Set{module}

	return module
end