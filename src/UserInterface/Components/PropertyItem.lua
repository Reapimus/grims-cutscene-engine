local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local stateHandler = require(script.Parent.StateHandler)
local propertyWatcher = require(script.Parent.PropertyWatcher)
local updateInstances = require(script.Parent.UpdateInstances)

local DELETE_ICON = "rbxasset://textures/CollisionGroupsEditor/delete.png"
local DELETE_ICON_HOVER = "rbxasset://textures/CollisionGroupsEditor/delete-hover.png"

return function(instance, property)
	local button = Instance.new("TextButton")
	button.Name = instance:GetDebugId().."_"..property
	button.Text = ""
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(1,0,0,25)

	local tag = Instance.new("ObjectValue")
	tag.Name = "AssociatedInstance"
	tag.Value = instance
	tag.Parent = button

	local propTag = Instance.new("StringValue")
	propTag.Name = "Property"
	propTag.Value = property
	propTag.Parent = button

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,35,0,0)
	label.Size = UDim2.new(1,-35,1,0)
	label.Text = property
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button
	themeHandler:SyncColors(label, "TextColor3", Enum.StudioStyleGuideColor.MainText)

	local hoverFrame = Instance.new("Frame")
	hoverFrame.BorderSizePixel = 2
	hoverFrame.BorderMode = Enum.BorderMode.Inset
	hoverFrame.Size = UDim2.new(500,0,1,0)
	hoverFrame.BackgroundTransparency = 0
	hoverFrame.ZIndex = -2
	hoverFrame.Visible = false
	hoverFrame.Parent = button
	hoverFrame.Name = "HoverFrame"
	themeHandler:SyncColors(hoverFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Hover)
	themeHandler:SyncColors(hoverFrame, "BorderColor3", Enum.StudioStyleGuideColor.ButtonBorder)

	local selectedFrame = Instance.new("Frame")
	selectedFrame.BorderSizePixel = 0
	selectedFrame.Size = UDim2.new(500,0,1,0)
	selectedFrame.BackgroundTransparency = 0
	selectedFrame.ZIndex = -1
	selectedFrame.Parent = button
	selectedFrame.Visible = false
	selectedFrame.BackgroundColor3 = Color3.fromRGB(104, 148, 217)
	selectedFrame.Name = "SelectedFrame"

	button.MouseEnter:Connect(function()
		hoverFrame.Visible = true
	end)

	button.MouseLeave:Connect(function()
		hoverFrame.Visible = false
	end)

	local addButton = Instance.new("ImageButton")
	addButton.BackgroundTransparency = 1
	addButton.Image = DELETE_ICON
	addButton.Size = UDim2.new(0,20,0,20)
	addButton.Position = UDim2.new(1,-25,0,3)
	addButton.Parent = button

	addButton.MouseButton1Click:Connect(function()
		local cutsceneData = stateHandler.LoadedCutsceneData
		if cutsceneData.Keyframes[instance] then
			updateInstances(0, {instance}, cutsceneData)
			cutsceneData.Keyframes[instance][property] = nil
			stateHandler:CutsceneUpdated()
		end

		propertyWatcher:StopTracking(instance, property)
		button:Destroy()
	end)

	addButton.MouseEnter:Connect(function()
		addButton.Image = DELETE_ICON_HOVER
	end)

	addButton.MouseLeave:Connect(function()
		addButton.Image = DELETE_ICON
	end)

	local nameConnection = instance:GetPropertyChangedSignal("Name"):Connect(function()
		label.Text = instance.Name
		button.Name = instance.Name
	end)

	local ancestryConnection
	ancestryConnection = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			-- Cleanup because object destroyed
			nameConnection:Disconnect()
			ancestryConnection:Disconnect()
		end
	end)

	return button
end