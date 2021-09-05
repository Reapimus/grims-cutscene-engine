local themeHandler = require(script.Services.ThemeHandler)
local stateHandler = require(script.Components.StateHandler)
local createCutscenePrompt = require(script.Components.CreateCutscenePrompt)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(pluginGui)
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Size = UDim2.new(1,0,1,0)
	backgroundFrame.Name = "MainFrame"
	backgroundFrame.Parent = pluginGui
	themeHandler:SyncColors(backgroundFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)

	local topbar = require(script.Components.Topbar)()
	topbar.Parent = backgroundFrame

	local editor = require(script.Components.Editor)()
	editor.Parent = backgroundFrame

	pluginGui.WindowFocused:Connect(function()
		stateHandler.IsFocused = true
	end)

	pluginGui.WindowFocusReleased:Connect(function()
		stateHandler.IsFocused = false
	end)

	stateHandler.PluginGUI = pluginGui

	if ReplicatedStorage:FindFirstChild("ExportedCutscenes") == nil or #ReplicatedStorage.ExportedCutscenes:GetChildren() == 0 then
		createCutscenePrompt().Parent = pluginGui
	end

	if ReplicatedStorage:FindFirstChild("ExportedCutscenes") and #ReplicatedStorage.ExportedCutscenes:GetChildren() > 0 then
		stateHandler:LoadCutscene(ReplicatedStorage.ExportedCutscenes:GetChildren()[1].Name)
	end

	return backgroundFrame
end