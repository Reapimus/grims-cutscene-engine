local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local topbarButton = require(script.Parent.TopbarButton)
local topbarDropdown = require(script.Parent.TopbarDropdown)
local stateHandler = require(script.Parent.StateHandler)
local updateInstances = require(script.Parent.UpdateInstances)
local renameCutscene = require(script.Parent.RenameCutscene)
local exporter = require(script.Parent.Exporter)
local createCutscenePrompt = require(script.Parent.CreateCutscenePrompt)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function()
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.ZIndex = 99999
	topbar.BorderSizePixel = 1
	topbar.Size = UDim2.new(1,0,0,25)
	themeHandler:SyncColors(topbar, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(topbar, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	stateHandler.Topbar = topbar

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0,2)
	padding.PaddingRight = UDim.new(0,2)
	padding.PaddingTop = UDim.new(0,2)
	padding.PaddingBottom = UDim.new(0,2)
	padding.Parent = topbar

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.Padding = UDim.new(0,3)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	listLayout.Parent = topbar

	local saveButton = topbarButton("rbxassetid://6208600451")
	saveButton.LayoutOrder = 1
	saveButton.Parent = topbar

	saveButton.MouseButton1Down:Connect(function()
		exporter(stateHandler.CurrentCutscene, stateHandler.LoadedCutsceneData)
	end)

	local previewButton = topbarButton("rbxassetid://6208593977")
	previewButton.LayoutOrder = 2
	previewButton.Parent = topbar

	previewButton.MouseButton1Down:Connect(function()
		local player = stateHandler.ActiveCutscenePlayer
		if player then
			stateHandler.Previewing = true
			player:Play()
			player.DonePlaying:Wait()
			stateHandler.Previewing = false
			local instances = {}
			for i, _ in pairs(stateHandler.LoadedCutsceneData.Keyframes) do
				table.insert(instances, i)
			end

			updateInstances(stateHandler.Timeline.CursorPos.Value/10, instances, stateHandler.LoadedCutsceneData)
		end
	end)

	local reloadButton = topbarButton("rbxassetid://6208592812")
	reloadButton.LayoutOrder = 3
	reloadButton.Parent = topbar

	reloadButton.MouseButton1Down:Connect(function()
		stateHandler:LoadCutscene(stateHandler.CurrentCutscene)
	end)

	local cutscenes = {"Create New Cutscene"}
	if ReplicatedStorage:FindFirstChild("ExportedCutscenes") then
		cutscenes = {}
		for _, v in pairs(ReplicatedStorage.ExportedCutscenes:GetChildren()) do
			table.insert(cutscenes, v.Name)
		end
		table.insert(cutscenes, "Create New Cutscene")
	end

	local currentCutscene = topbarDropdown("Editing", cutscenes)
	currentCutscene.Name = "CurrentCutscene"
	currentCutscene.LayoutOrder = 4
	currentCutscene.Parent = topbar

	currentCutscene.OptionChosen:Connect(function(newOption)
		if newOption == "Create New Cutscene" and #ReplicatedStorage.ExportedCutscenes:GetChildren() > 0 then
			stateHandler:NewCutscene()
		else
			if newOption ~= "Create New Cutscene" then
				stateHandler:LoadCutscene(newOption)
			end
		end
	end)

	local function generateCutsceneOptions(firstTime)
		cutscenes = {}
		for _, v in pairs(ReplicatedStorage.ExportedCutscenes:GetChildren()) do
			table.insert(cutscenes, v.Name)
		end
		table.insert(cutscenes, "Create New Cutscene")
		currentCutscene:SetOptions(cutscenes)
	end

	local function HandleExported(child)
		if child.Name == "ExportedCutscenes" then
			child.ChildAdded:Connect(generateCutsceneOptions)
			child.ChildRemoved:Connect(generateCutsceneOptions)

			child.ChildRemoved:Connect(function()
				if #ReplicatedStorage.ExportedCutscenes:GetChildren() == 0 then
					createCutscenePrompt().Parent = stateHandler.PluginGUI
				end
			end)
		end
	end

	ReplicatedStorage.ChildAdded:Connect(HandleExported)
	for _, v in pairs(ReplicatedStorage:GetChildren()) do
		HandleExported(v)
	end

	local renameButton = topbarButton("rbxassetid://6208590612")
	renameButton.Name = "Rename"
	renameButton.LayoutOrder = 5
	renameButton.Parent = topbar

	renameButton.MouseButton1Down:Connect(function()
		renameCutscene().Parent = stateHandler.PluginGUI
	end)

	local deleteButton = topbarButton("rbxassetid://6208592012")
	deleteButton.Name = "Delete"
	deleteButton.LayoutOrder = 6
	deleteButton.Parent = topbar

	deleteButton.MouseButton1Down:Connect(function()
		stateHandler:DeleteCutscene()
	end)

	local easingStyles = {}
	local easingDirections = {}

	for _, v in pairs(Enum.EasingStyle:GetEnumItems()) do
		table.insert(easingStyles, v.Name)
	end

	for _, v in pairs(Enum.EasingDirection:GetEnumItems()) do
		table.insert(easingDirections, v.Name)
	end

	local easingStyle = topbarDropdown("EasingStyle", easingStyles)
	easingStyle.Name = "EasingStyle"
	easingStyle.LayoutOrder = 9
	easingStyle.Visible = false
	easingStyle.Parent = topbar

	local easingDirection = topbarDropdown("EasingDirection", easingDirections)
	easingDirection.Name = "EasingDirection"
	easingDirection.LayoutOrder = 10
	easingDirection.Visible = false
	easingDirection.Parent = topbar

	easingStyle.OptionChosen:Connect(function(newOption)
		stateHandler.EasingStyle = Enum.EasingStyle[newOption]
		if stateHandler.SelectedKeyframe then
			local cutsceneData = stateHandler.LoadedCutsceneData
			for _, frame in pairs(cutsceneData.Keyframes[stateHandler.SelectedKeyframe.Instance][stateHandler.SelectedKeyframe.Property].Frames) do
				if frame.Time == stateHandler.SelectedKeyframe.Time then
					frame.EasingStyle = stateHandler.EasingStyle
				end
			end
			stateHandler:CutsceneUpdated(true)
		end
	end)

	easingDirection.OptionChosen:Connect(function(newOption)
		stateHandler.EasingDirection = Enum.EasingDirection[newOption]
		if stateHandler.SelectedKeyframe then
			local cutsceneData = stateHandler.LoadedCutsceneData
			for _, frame in pairs(cutsceneData.Keyframes[stateHandler.SelectedKeyframe.Instance][stateHandler.SelectedKeyframe.Property].Frames) do
				if frame.Time == stateHandler.SelectedKeyframe.Time then
					frame.EasingDirection = stateHandler.EasingDirection
				end
			end
			stateHandler:CutsceneUpdated(true)
		end
	end)

	stateHandler.EasingStyleDropdown = easingStyle
	stateHandler.EasingDirectionDropdown = easingDirection
	stateHandler.CutsceneDropdown = currentCutscene

	local cameraButton = topbarButton("rbxassetid://6209576320")
	cameraButton.Name = "SnapshotCamera"
	cameraButton.LayoutOrder = 7
	cameraButton.Parent = topbar

	cameraButton.MouseButton1Down:Connect(function()
		local instanceItem = require(script.Parent.InstanceItem)
		local propertyItem = require(script.Parent.PropertyItem)
		local keyframe = require(script.Parent.Keyframe)

		local instance, prop = workspace.CurrentCamera, "CFrame"
		local cutsceneData = stateHandler.LoadedCutsceneData

		if cutsceneData.Keyframes[instance] == nil then
			cutsceneData.Keyframes[instance] = {}

			instanceItem(instance).Parent = stateHandler.Explorer
		end

		local time = stateHandler.Timeline.CursorPos.Value

		if cutsceneData.Keyframes[instance][prop] then
			if time == 0 then
				cutsceneData.Keyframes[instance][prop].InitialValue = instance[prop]
			else
				for _, v in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
					if v.Time == time/10 then
						v.Value = instance[prop]
						stateHandler:CutsceneUpdated(true)
						return
					end
				end

				table.insert(cutsceneData.Keyframes[instance][prop].Frames, {
					Time = time/10;
					Value = instance[prop];
					EasingStyle = Enum.EasingStyle.Linear;
					EasingDirection = Enum.EasingDirection.In;
				})

				keyframe(instance, prop, time)
				stateHandler:CutsceneUpdated(true)
			end
		else
			cutsceneData.Keyframes[instance][prop] = {
				InitialValue = instance[prop];
				Frames = {

				};
			}

			propertyItem(instance, prop).Parent = stateHandler.Explorer
			keyframe(instance, prop, 0)

			if time ~= 0 then
				table.insert(cutsceneData.Keyframes[instance][prop].Frames, {
					Time = time/10;
					Value = instance[prop];
					EasingStyle = Enum.EasingStyle.Linear;
					EasingDirection = Enum.EasingDirection.In;
				})

				keyframe(instance, prop, time)
				stateHandler:CutsceneUpdated(true)
			end
		end
	end)

	local jointButton = topbarButton("rbxassetid://6215509129")
	jointButton.Name = "SetupJoints"
	jointButton.LayoutOrder = 8
	jointButton.Visible = false
	jointButton.Parent = topbar

	jointButton.MouseButton1Down:Connect(function()
		local sel = game:GetService("Selection"):Get()[1]

		local jointProps = {"C0","C1"}

		if sel then
			local instanceItem = require(script.Parent.InstanceItem)
			local propertyItem = require(script.Parent.PropertyItem)
			local propertyWatcher = require(script.Parent.PropertyWatcher)
			local keyframe = require(script.Parent.Keyframe)

			local cutsceneData = stateHandler.LoadedCutsceneData

			for _, instance in pairs(sel:GetDescendants()) do
				if instance:IsA"Motor6D" then
					if cutsceneData.Keyframes[instance] == nil then
						cutsceneData.Keyframes[instance] = {}
						instanceItem(instance).Parent = stateHandler.Explorer
					end
					for _, prop in pairs(jointProps) do
						if cutsceneData.Keyframes[instance][prop] == nil then
							cutsceneData.Keyframes[instance][prop] = {
								InitialValue = instance[prop];
								Frames = {

								};
							}

							propertyItem(instance, prop).Parent = stateHandler.Explorer
							keyframe(instance, prop, 0)

							propertyWatcher:TrackProperty(instance, prop)
						end
					end
				end
			end
		end
	end)

	return topbar
end