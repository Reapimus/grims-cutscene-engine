local cutsceneData = {
	Actions = {};
	Keyframes = {};
}

for _, v in pairs(script.Keyframes:GetChildren()) do
	local instance = v:FindFirstChild("CameraInstance") and workspace.CurrentCamera or v.Instance.Value
	cutsceneData.Keyframes[instance] = require(v)
end

for _, v in pairs(script.Actions:GetChildren()) do
	table.insert(cutsceneData.Actions, require(v))
end

return cutsceneData