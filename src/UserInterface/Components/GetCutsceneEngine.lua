local ReplicatedStorage = game:GetService("ReplicatedStorage")
if ReplicatedStorage:FindFirstChild("CutsceneEngine", true) then
	return require(ReplicatedStorage:FindFirstChild("CutsceneEngine", true))
else
	--local cutsceneEngine = script.Parent.CutsceneEngine:Clone()
	--cutsceneEngine.Parent = ReplicatedStorage
	--return require(cutsceneEngine)
	return require(script.Parent.CutsceneEngine)
end