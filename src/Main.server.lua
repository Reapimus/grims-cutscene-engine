local DOCK_WIDGET_INFO = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Bottom,
	false, true, 800, 250, 400, 200
)

local toolbar = plugin:CreateToolbar("Cutscene Engine")
local mainButton = toolbar:CreateButton("Cutscene Editor", "Create cutscenes for use with the cutscene engine", "rbxassetid://6197831913")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local pluginGui = plugin:CreateDockWidgetPluginGui("CutsceneEngineEditor", DOCK_WIDGET_INFO)
pluginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pluginGui.Title = "Cutscene Engine Editor"
pluginGui.Name = "CutsceneEngineEditor"
plugin.Name = "CutsceneEngineEditor"

local UserInterface = require(script.Parent.UserInterface)
local stateHandler = require(script.Parent.UserInterface.Components.StateHandler)
local hasInitialized = false

local function updateState()
	mainButton:SetActive(pluginGui.Enabled)
	stateHandler.Recording = pluginGui.Enabled

	if not pluginGui.Enabled then
		stateHandler.Clipboard = nil
	end

	if pluginGui.Enabled then
		if not hasInitialized and RunService:IsEdit() then
			hasInitialized = true
			UserInterface(pluginGui)
			stateHandler:Init(plugin)
		end
		if not ReplicatedStorage:FindFirstChild("ExportedCutscenes") then
			local folder = Instance.new("Folder")
			folder.Name = "ExportedCutscenes"
			folder.Parent = ReplicatedStorage
		end

		if not ReplicatedStorage:FindFirstChild("CutsceneEngine") then
			local engine = script.Parent.UserInterface.Components.CutsceneEngine:Clone()
			engine.Parent = ReplicatedStorage
		end
	end
end

updateState()
pluginGui:GetPropertyChangedSignal("Enabled"):Connect(updateState)

if RunService:IsEdit() then
	mainButton.Enabled = true
	mainButton.Click:Connect(function()
		pluginGui.Enabled = not pluginGui.Enabled
	end)
else
	mainButton.Enabled = false
end