local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local stateHandler = require(script.Parent.StateHandler)
local updateInstances = require(script.Parent.UpdateInstances)

return function(instance, prop, time)
	local button = Instance.new("ImageButton")
	button.BorderSizePixel = 3
	button.Size = UDim2.new(0, 11, 0, 11)
	button.AnchorPoint = Vector2.new(.5, .5)
	button.Rotation = 45
	button.ZIndex = 5
	button.AutoButtonColor = false
	themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button)
	themeHandler:SyncColors(button, "BorderColor3", Enum.StudioStyleGuideColor.ButtonBorder)

	button.Name = "Keyframe"

	local instanceTag = Instance.new("ObjectValue")
	instanceTag.Name = "AssociatedInstance"
	instanceTag.Value = instance
	instanceTag.Parent = button

	local propertyTag = Instance.new("StringValue")
	propertyTag.Name = "Property"
	propertyTag.Value = prop
	propertyTag.Parent = button

	local timeTag = Instance.new("NumberValue")
	timeTag.Name = "Time"
	timeTag.Value = time
	timeTag.Parent = button

	local dragging = false

	button.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	local function mouseMoved(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging then
				local backgroundFrame = stateHandler.Timeline
				local offset = backgroundFrame.Offset.Value
				local zoom = backgroundFrame.Zoom.Value
				local objStart,objEnd = backgroundFrame.AbsolutePosition.X, backgroundFrame.AbsolutePosition.X + backgroundFrame.AbsoluteSize.X
				local relativePos = math.clamp((inputObject.Position.X - objStart) / backgroundFrame.AbsoluteSize.X, 0, 1)
				local cursorPos = offset+math.round(relativePos*zoom)

				local cutsceneData = stateHandler.LoadedCutsceneData
				for _, frame in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
					if frame.Time == time/10 then
						frame.Time = cursorPos/10
						time = cursorPos
						timeTag.Value = cursorPos
					end
				end

				local instances = {}
				for i, _ in pairs(stateHandler.LoadedCutsceneData.Keyframes) do
					table.insert(instances, i)
				end

				updateInstances(cursorPos/10, instances, stateHandler.LoadedCutsceneData)

				for _, v in pairs(backgroundFrame:GetChildren()) do
					if v:FindFirstChild("AssociatedInstance") then
						local explorerObject
						for _, d in pairs(stateHandler.Explorer:GetChildren()) do
							if d:FindFirstChild("AssociatedInstance") and d.AssociatedInstance.Value == v.AssociatedInstance.Value then
								if d.Property.Value == v.Property.Value then
									explorerObject = d
									break
								end
							end
						end

						if explorerObject then
							local time = v.Time.Value
							v.Visible = time >= offset and time <= offset + zoom
							v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5) -- (25*(explorerObject.LayoutOrder)+10)
						else
							v:Destroy()
						end
					end
				end
			end
		end
	end

	local ev = stateHandler.Timeline.InputChanged:Connect(mouseMoved)

	button.AncestryChanged:Connect(function(_, parent)
		if not parent then
			ev:Disconnect()
		end
	end)

	button.InputChanged:Connect(mouseMoved)

	button.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local function clicked()
		for _, v in pairs(stateHandler.Timeline:GetChildren()) do
			if v:FindFirstChild"AssociatedInstance" then
				if v.AssociatedInstance.Value == instance and v.Property.Value == prop and v.Time.Value == time then
					themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
					button.BorderSizePixel = 0
				else
					themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button)
					button.BorderSizePixel = 3
				end
			end
		end

		local cutsceneData = stateHandler.LoadedCutsceneData
		for _, frame in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
			if frame.Time == time/10 then
				stateHandler.EasingStyleDropdown:SetCurrent(frame.EasingStyle.Name)
				stateHandler.EasingDirectionDropdown:SetCurrent(frame.EasingDirection.Name)
				break
			end
		end

		stateHandler.SelectedKeyframe = {
			Time = time;
			Instance = instance;
			Property = prop;
			Type = "Tween";
		}

		stateHandler.Topbar.EasingDirection.Visible = true
		stateHandler.Topbar.EasingStyle.Visible = true
	end

	button.MouseButton2Down:Connect(function()
		clicked()
		stateHandler.KeyframeMenu:ShowAsync()
	end)

	button.MouseButton1Down:Connect(clicked)

	button.Parent = stateHandler.Timeline

	return button
end