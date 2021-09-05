local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local stateHandler = require(script.Parent.StateHandler)
local updateInstances = require(script.Parent.UpdateInstances)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RealCutsceneEngine
if ReplicatedStorage:FindFirstChild("CutsceneEngine") then
	RealCutsceneEngine = ReplicatedStorage.CutsceneEngine
else
	RealCutsceneEngine = script.Parent.CutsceneEngine
end

local colors = {}

for i, v in pairs(RealCutsceneEngine.Actions:GetChildren()) do
	colors[v.Name] = Color3.fromHSV((i%10)/10,1,1)
end

return function(name, action)
	local button = Instance.new("ImageButton")
	button.BorderSizePixel = 3
	button.Size = UDim2.new(0, 11, 0, 11)
	button.AnchorPoint = Vector2.new(.5, .5)
	button.Rotation = 45
	button.ZIndex = 5
	button.AutoButtonColor = false
	button.BorderColor3 = colors[name]
	themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button)

	button.Name = "Action"

	if action.Target then
		local instanceTag = Instance.new("ObjectValue")
		instanceTag.Name = "Target"
		instanceTag.Value = action.Target
		instanceTag.Parent = button
	end

	local timeTag = Instance.new("NumberValue")
	timeTag.Name = "Time"
	timeTag.Value = action.Time
	timeTag.Parent = button

	local actionTag = Instance.new("StringValue")
	actionTag.Name = "Action"
	actionTag.Value = name
	actionTag.Parent = button

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
				for _, frame in pairs(cutsceneData.Actions) do
					if frame.Time == action.Time/10 then
						frame.Time = cursorPos/10
						action.Time = cursorPos
						timeTag.Value = cursorPos
					end
				end

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
							v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5)
						else
							v:Destroy()
						end
					elseif v:FindFirstChild("Action") then
						if v:FindFirstChild("Target") then
							local explorerObject
							for _, d in pairs(stateHandler.Explorer:GetChildren()) do
								if d:FindFirstChild("OriginalInstance") and d.OriginalInstance.Value == v.Target.Value then
									explorerObject = d
									break
								end
							end

							if explorerObject then
								local time = v.Time.Value
								v.Visible = time >= offset and time <= offset + zoom
								v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5)
							else
								v:Destroy()
							end
						else
							local time = v.Time.Value
							v.Visible = time >= offset and time <= offset + zoom
							v.Position = UDim2.new(((time-offset)/zoom), 0, 0, 25+10)
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
				themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
				button.BorderSizePixel = 0
			elseif v:FindFirstChild"Action" then
				if v.Action.Value == name and (not action.Target or action.Target and v.Target.Value == action.Target) and v.Time.Value == action.Time then
					themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
					button.BorderSizePixel = 2
				else
					themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button)
					button.BorderSizePixel = 3
				end
			end
		end

		stateHandler:SetupActionCustomization(name, action)

		local copiedAction = {}

		for i, v in pairs(action) do
			if i ~= "Time" then
				copiedAction[i] = v
			end
		end

		stateHandler.SelectedKeyframe = {
			Time = action.Time;
			Action = name;
			Settings = copiedAction;
			Type = "Action";
		}
	end

	button.MouseButton2Down:Connect(function()
		clicked()
		stateHandler.KeyframeMenu:ShowAsync()
	end)

	button.MouseButton1Down:Connect(clicked)

	button.Parent = stateHandler.Timeline

	return button
end