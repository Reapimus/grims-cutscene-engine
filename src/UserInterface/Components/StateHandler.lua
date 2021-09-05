local module = {}
local CutsceneEngine = require(script.Parent.GetCutsceneEngine)
local exporter = require(script.Parent.Exporter)
local topbarInput = require(script.Parent.TopbarInput)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local RealCutsceneEngine
if ReplicatedStorage:FindFirstChild("CutsceneEngine") then
	RealCutsceneEngine = ReplicatedStorage.CutsceneEngine
else
	RealCutsceneEngine = script.Parent.CutsceneEngine
end

module.IsFocused = false
module.IsPlaying = false
module.CurrentCutscene = ""
module.ActiveCutscenePlayer = nil
module.LoadedCutsceneData = {
	Actions = {};
	Keyframes = {};
}

module.Timeline = nil
module.Topbar = nil
module.Explorer = nil
module.PluginGUI = nil

module.EasingStyleDropdown = nil
module.EasingDirectionDropdown = nil
module.CutsceneDropdown = nil

module.Recording = false
module.Updating = false
module.ResettingValues = false
module.Previewing = false

module.EasingStyle = Enum.EasingStyle.Linear
module.EasingDirection = Enum.EasingDirection.In

module.SelectedKeyframe = nil
module.KeyframeActions = nil
module.TimelineActions = nil

module.TimelineMenu = nil
module.KeyframeMenu = nil

function module:Init(plugin)
	module.KeyframeActions = {
		Copy = plugin:CreatePluginAction("CutsceneEngine_CopyKeyframe", "Copy Keyframe", "Copy the selected keyframe");
		Delete = plugin:CreatePluginAction("CutsceneEngine_DeleteKeyframe", "Delete Keyframe", "Delete the selected keyframe");
	}

	module.KeyframeActions.Copy.Triggered:Connect(function()
		if module.Recording and module.SelectedKeyframe then
			module.Clipboard = module.SelectedKeyframe
		end
	end)

	module.KeyframeActions.Delete.Triggered:Connect(function()
		if module.Recording and module.SelectedKeyframe then
			local cutsceneData,instance,prop = module.LoadedCutsceneData,module.SelectedKeyframe.Instance,module.SelectedKeyframe.Property
			for i, frame in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
				if frame.Time == module.SelectedKeyframe.Time then
					if module.Clipboard == frame then
						module.Clipboard = nil
					end

					table.remove(cutsceneData.Keyframes[instance][prop].Frames, i)
					for _, v in pairs(module.Timeline:GetChildren()) do
						if v:FindFirstChild"AssociatedInstance" and v.AssociatedInstance.Value == instance and v.Property.Value == prop and v.Time.Value == frame.Time then
							v:Destroy()
						end
					end

					break
				end
			end
		end
	end)

	module.KeyframeMenu = plugin:CreatePluginMenu("CutsceneEngine_KeyframeContext")
	module.KeyframeMenu:AddAction(module.KeyframeActions.Copy)
	module.KeyframeMenu:AddAction(module.KeyframeActions.Delete)

	module.TimelineActions = {
		Paste = plugin:CreatePluginAction("CutsceneEngine_PasteKeyframe", "Paste Keyframe", "Paste a keyframe from the clipboard");
	}

	module.TimelineMenu = plugin:CreatePluginMenu("CutsceneEngine_TimelineContext")

	module.TimelineMenu:AddAction(module.TimelineActions.Paste)
	module.TimelineMenu:AddSeparator()

	module.TimelineActions.Paste.Triggered:Connect(function()
		if module.Recording and module.Timeline.CursorPos.Value ~= 0 then
			local actionKeyframe = require(script.Parent.ActionKeyframe)
			local keyframe = require(script.Parent.Keyframe)
			local clipboard = module.Clipboard

			if clipboard then
				if clipboard.Type == "Tween" then
					local cutsceneData = module.LoadedCutsceneData
					local time = module.Timeline.CursorPos.Value
					local instance, prop = clipboard.Instance, clipboard.Property

					local value
					for _, v in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
						if v.Time == clipboard.Time/10 then
							value = v.Value
						end
					end

					if clipboard.Time == 0 then
						value = cutsceneData.Keyframes[instance][prop].InitialValue
					end

					if value == nil then
						return
					end

					for _, v in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
						if v.Time == time/10 then
							v.Value = value
							module:CutsceneUpdated(true)
							return
						end
					end

					table.insert(cutsceneData.Keyframes[instance][prop].Frames, {
						Time = time/10;
						Value = value;
						EasingStyle = Enum.EasingStyle.Linear;
						EasingDirection = Enum.EasingDirection.In;
					})

					keyframe(instance, prop, time)
					module:CutsceneUpdated(true)
				elseif clipboard.Type == "Action" then
					local data = require(RealCutsceneEngine.Actions:FindFirstChild(clipboard.Action))
					local cutsceneData = module.LoadedCutsceneData
					for _, v in pairs(cutsceneData.Actions) do
						if v.Name == clipboard.Action and v.Time == module.Timeline.CursorPos.Value/10 then
							for i, d in pairs(clipboard.Settings) do
								if i ~= "Name" and i ~= "Time" then
									v[i] = d
								end
							end
							return
						end
					end
					if data.HasTarget then
						local sel = Selection:Get()[1]

						if sel then
							local newInfo = {Time = module.Timeline.CursorPos.Value, Target = sel}
							local newInfo2 = {Time = module.Timeline.CursorPos.Value/10, Name=clipboard.Action, Target = sel}
							for i, v in pairs(clipboard.Settings) do
								newInfo[i] = v
								newInfo2[i] = v
							end
							table.insert(cutsceneData.Actions, newInfo2)
							actionKeyframe(clipboard.Action, newInfo)
						end
					else
						local newInfo = {Time = module.Timeline.CursorPos.Value}
						local newInfo2 = {Time = module.Timeline.CursorPos.Value/10, Name=clipboard.Action}
						for i, v in pairs(clipboard.Settings) do
							newInfo[i] = v
							newInfo2[i] = v
						end
						table.insert(cutsceneData.Actions, newInfo2)
						actionKeyframe(clipboard.Action, newInfo)
					end
				end
			end
		end
	end)

	spawn(function()
		local actionKeyframe = require(script.Parent.ActionKeyframe)
		for _, v in pairs(RealCutsceneEngine.ActionConfig:GetChildren()) do
			local data = require(v)
			local action = module.TimelineMenu:AddNewAction("CutsceneEngine_Add"..v.Name, "Add "..v.Name)

			action.Triggered:Connect(function()
				local cutsceneData = module.LoadedCutsceneData
				if data.HasTarget then
					local sel = Selection:Get()[1]

					if sel then
						local newInfo = {Time = module.Timeline.CursorPos.Value, Target = sel}
						local newInfo2 = {Time = module.Timeline.CursorPos.Value/10, Target = sel, Name=v.Name}
						for i, v in pairs(data.Settings) do
							newInfo[i] = v
							newInfo2[i] = v
						end
						table.insert(cutsceneData.Actions, newInfo2)
						actionKeyframe(v.Name, newInfo)
					end
				else
					local newInfo = {Time = module.Timeline.CursorPos.Value}
					local newInfo2 = {Time = module.Timeline.CursorPos.Value/10, Name=v.Name}
					for i, v in pairs(data.Settings) do
						newInfo[i] = v
						newInfo2[i] = v
					end
					table.insert(cutsceneData.Actions, newInfo2)
					actionKeyframe(v.Name, newInfo)
				end
			end)
		end
	end)
end

module.Clipboard = nil

local actionCustomizables = {}

function module:ClearActionCustomization()
	for i, v in pairs(actionCustomizables) do
		v:Destroy()
		actionCustomizables[i] = nil
	end
end

function module:SetupActionCustomization(name, action)
	module:ClearActionCustomization()

	local data = require(RealCutsceneEngine.ActionConfig:FindFirstChild(name))
	for i, v in pairs(action) do
		if data.Settings[i] then
			local input = topbarInput(i)
			input.Text = v
			input.LayoutOrder = 10
			input.Parent = module.Topbar
			table.insert(actionCustomizables, input)

			input.FocusLost:Connect(function(en)
				if en then
					local result = input.Text
					if typeof(v) == "number" then
						result = tonumber(result)
					end

					if result then
						v = result
						action[i] = result
						local cutsceneData = module.LoadedCutsceneData
						for d, x in pairs(cutsceneData.Actions) do
							if x.Time == action.Time/10 and (not data.HasTarget or x.Target == action.Target) then
								x[i] = result
								module:CutsceneUpdated(true)
								break
							end
						end
					else
						input.Text = v
					end
				end
			end)
		end
	end
end

function module:SetupCutsceneData()
	local instanceItem = require(script.Parent.InstanceItem)
	local propertyItem = require(script.Parent.PropertyItem)
	local keyframe = require(script.Parent.Keyframe)
	local actionKeyframe = require(script.Parent.ActionKeyframe)
	local propertyWatcher = require(script.Parent.PropertyWatcher)

	print("Setting up cutscene data")
	-- Clear action customization options
	module:ClearActionCustomization()
	-- Clear timeline keyframes
	for _, v in pairs(module.Timeline:GetChildren()) do
		if v:FindFirstChild"AssociatedInstance" or v:FindFirstChild"Action" then
			v:Destroy()
		end
	end
	-- Clear explorer items
	for _, v in pairs(module.Explorer:GetChildren()) do
		if v:FindFirstChild"AssociatedInstance" or v:FindFirstChild"OriginalInstance" then
			v:Destroy()
		end
	end
	-- Clear property watcher
	propertyWatcher:Clear()
	-- Setup explorer items and tween keyframes
	for i, v in pairs(module.LoadedCutsceneData.Keyframes) do
		local instance = instanceItem(i)
		instance.Parent = module.Explorer

		for name, values in pairs(v) do
			local property = propertyItem(i, name)
			property.Parent = module.Explorer

			keyframe(i, name, 0)
			propertyWatcher:TrackProperty(i, name)

			for _, frame in pairs(values.Frames) do
				keyframe(i, name, frame.Time*10)
			end
		end
	end
	-- Setup action keyframes
	for _, v in pairs(module.LoadedCutsceneData.Actions) do
		local clone = {}
		for i, d in pairs(v) do
			if i == "Time" then
				clone[i] = d*10
			else
				clone[i] = d
			end
		end
		actionKeyframe(v.Name, clone)
	end
end

function module:LoadCutscene(name)
	if ReplicatedStorage:FindFirstChild("ExportedCutscenes") == nil then
		warn("ExportedCutscenes folder missing.")
		return
	end
	local cutscene = ReplicatedStorage.ExportedCutscenes:FindFirstChild(name)
	if cutscene then
		module.CurrentCutscene = name
		module.LoadedCutsceneData = require(cutscene:Clone())
		module.CutsceneDropdown:SetCurrent(module.CurrentCutscene, false)
		module:SetupCutsceneData()
		module:CutsceneUpdated()
	else
		warn(string.format("Cutscene with name '%s' does not exist.", name))
	end
end

function module:DeleteCutscene(name)
	local folder = ReplicatedStorage:FindFirstChild("ExportedCutscenes")
	if folder then
		local cutscene = folder:FindFirstChild(module.CurrentCutscene)
		if cutscene then
			cutscene:Destroy()
			ChangeHistoryService:SetWaypoint(string.format("Deleted Cutscene %s", module.CurrentCutscene))

			if #folder:GetChildren() > 0 then
				module:LoadCutscene(folder:GetChildren()[1].Name)
			else
				module.CurrentCutscene = ""
			end
		end
	end

	module:CutsceneUpdated()
	module.CutsceneDropdown:SetCurrent(module.CurrentCutscene, true)
	module:SetupCutsceneData()
end

function module:RenameCutscene(name)
	local folder = ReplicatedStorage:FindFirstChild("ExportedCutscenes")
	if folder then
		local cutscene = folder:FindFirstChild(module.CurrentCutscene)
		if cutscene then
			cutscene.Name = name
			ChangeHistoryService:SetWaypoint(string.format("Renamed Cutscene %s from %s", module.CurrentCutscene, name))
			module.CurrentCutscene = name
		end
	end

	local cutscenes = {}
	for _, v in pairs(ReplicatedStorage.ExportedCutscenes:GetChildren()) do
		table.insert(cutscenes, v.Name)
	end
	table.insert(cutscenes, "Create New Cutscene")
	module.CutsceneDropdown:SetOptions(cutscenes)

	module.CurrentCutscene = name
	module.CutsceneDropdown:SetCurrent(module.CurrentCutscene, true)
end

function module:NewCutscene()
	local folder = ReplicatedStorage:FindFirstChild("ExportedCutscenes")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "ExportedCutscenes"
		folder.Parent = ReplicatedStorage
	end

	module.LoadedCutsceneData = {
		Actions = {};
		Keyframes = {};
	}

	local newCutsceneIndex = -1
	for _, v in pairs(folder:GetChildren()) do
		if string.sub(v.Name, 1, 11) == "NewCutscene" then
			local num = tonumber(string.sub(v.Name, 12))
			if num and num > newCutsceneIndex then
				newCutsceneIndex = num
			elseif num == nil and newCutsceneIndex < 1 then
				newCutsceneIndex = 0
			end
		end
	end

	local new = string.format("NewCutscene%s", newCutsceneIndex > -1 and newCutsceneIndex + 1 or "")
	module.CurrentCutscene = new
	--module.CutsceneDropdown:SetCurrent(module.CurrentCutscene, true)
	--module:SetupCutsceneData()

	exporter(module.CurrentCutscene, module.LoadedCutsceneData)
	ChangeHistoryService:SetWaypoint(string.format("Created Cutscene %s", module.CurrentCutscene))
	module:LoadCutscene(new)

	--module:CutsceneUpdated()
end

function module:CutsceneUpdated(dontReset)
	if module.ActiveCutscenePlayer and not dontReset then
		module.ResettingValues = true
		module.ActiveCutscenePlayer:ResetValues()
		module.ActiveCutscenePlayer = nil
		module.ResettingValues = false
	end
	if module.LoadedCutsceneData then
		module.ActiveCutscenePlayer = CutsceneEngine.new(module.LoadedCutsceneData)
	else
		module.ActiveCutscenePlayer = nil
	end
end

return module
