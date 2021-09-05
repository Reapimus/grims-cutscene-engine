local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local timelineTick = require(script.Parent.TimelineTick)
local stateHandler = require(script.Parent.StateHandler)
local updateInstances = require(script.Parent.UpdateInstances)

local SENSITIVITY = .1

return function()
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.BackgroundTransparency = 1
	backgroundFrame.Name = "Timeline"
	backgroundFrame.Position = UDim2.new(0,252,0,0)
	backgroundFrame.Size = UDim2.new(1,-252,1,0)
	backgroundFrame.BorderSizePixel = 0
	backgroundFrame.ZIndex = 1
	themeHandler:SyncColors(backgroundFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(backgroundFrame, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 25)
	padding.PaddingRight = UDim.new(0, 25)
	padding.Parent = backgroundFrame

	local cursor = Instance.new("Frame")
	cursor.Active = false
	cursor.BorderSizePixel = 0
	cursor.Size = UDim2.new(0, 3, 1, 0)
	cursor.AnchorPoint = Vector2.new(.5, 0)
	cursor.ZIndex = 2
	cursor.Parent = backgroundFrame
	themeHandler:SyncColors(cursor, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)

	local cursorTime = Instance.new("TextLabel")
	cursorTime.Active = false
	cursorTime.BorderSizePixel = 0
	cursorTime.Size = UDim2.new(0, 20, 0, 20)
	cursorTime.AnchorPoint = Vector2.new(.5, 0)
	cursorTime.Position = UDim2.new(.5, 0, 0, 0)
	cursorTime.TextYAlignment = Enum.TextYAlignment.Center
	cursorTime.Text = "0"
	cursorTime.Parent = cursor
	themeHandler:SyncColors(cursorTime, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
	themeHandler:SyncColors(cursorTime, "TextColor3", Enum.StudioStyleGuideColor.MainText)

	local offset = 0
	local cursorPos = 0
	local zoom = 12
	local ticks = {}

	local cursorValue = Instance.new("NumberValue")
	cursorValue.Name = "CursorPos"
	cursorValue.Parent = backgroundFrame

	local offsetValue = Instance.new("NumberValue")
	offsetValue.Name = "Offset"
	offsetValue.Parent = backgroundFrame

	local zoomValue = Instance.new("NumberValue")
	zoomValue.Name = "Zoom"
	zoomValue.Value = 12
	zoomValue.Parent = backgroundFrame

	for i = 1, 31 do
		local newTick = timelineTick()
		newTick.Name = "Tick"..i
		newTick.Parent = backgroundFrame
		table.insert(ticks, newTick)
	end

	local function update()
		offsetValue.Value = offset
		zoomValue.Value = zoom
		cursorValue.Value = cursorPos

		cursor.Position = UDim2.new((cursorPos-offset)/zoom, 0, 0, 0)
		cursor.Visible = cursorPos >= offset and cursorPos <= offset + zoom
		cursorTime.Text = cursorPos/10

		for i, v in pairs(ticks) do
			v.Visible = i <= zoom
			v.Time.Text = (offset+i-1)/10
			v.Position = UDim2.new((i-1)/zoom, 0, 0, 0)
			--v.Line.Size = zoom < 25 and UDim2.new(1, 0, 1, -20) or UDim2.new(1, 0, 1, -40)
			--v.Line.Position = zoom < 25 and UDim2.new(0, 0, 0, 20) or UDim2.new(0, 0, 0, 40)
			v.Time.Visible = (zoom < 27) or (((offset+i-1)/10)%.5 == 0)
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
					v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5) -- (25*(explorerObject.LayoutOrder)+10)
					v.Visible = time >= offset and time <= offset + zoom and v.Position.Y.Offset > 25
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
						v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5) -- (25*(explorerObject.LayoutOrder)+10)
						v.Visible = time >= offset and time <= offset + zoom and v.Position.Y.Offset > 25
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

	backgroundFrame.ChildAdded:Connect(update)
	backgroundFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
	stateHandler.Explorer:GetPropertyChangedSignal("CanvasPosition"):Connect(update)

	update()

	local dragging = false
	local cursorDragging = false

	local function cursorPosUpdate(inputObject)
		local objStart,objEnd = backgroundFrame.AbsolutePosition.X, backgroundFrame.AbsolutePosition.X + backgroundFrame.AbsoluteSize.X
		local relativePos = math.clamp((inputObject.Position.X - objStart) / backgroundFrame.AbsoluteSize.X, 0, 1)
		cursorPos = offset+math.round(relativePos*zoom)
		update()

		local instances = {}
		for i, _ in pairs(stateHandler.LoadedCutsceneData.Keyframes) do
			table.insert(instances, i)
		end

		updateInstances(cursorPos/10, instances, stateHandler.LoadedCutsceneData)
	end

	backgroundFrame.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton3 then
			dragging = true
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			cursorDragging = true
			cursorPosUpdate(inputObject)
			stateHandler:ClearActionCustomization()

			stateHandler.SelectedKeyframe = nil
			stateHandler.Topbar.EasingDirection.Visible = false
			stateHandler.Topbar.EasingStyle.Visible = false
			for _, v in pairs(backgroundFrame:GetChildren()) do
				if v:FindFirstChild"AssociatedInstance" or v:FindFirstChild("Action") then
					themeHandler:SyncColors(v, "BackgroundColor3", Enum.StudioStyleGuideColor.Button)
					v.BorderSizePixel = 3
				end
			end
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
			stateHandler.TimelineMenu:ShowAsync()
		end
	end)

	backgroundFrame.InputChanged:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(inputObject.Delta.x/SENSITIVITY,inputObject.Delta.y/SENSITIVITY) * .2

			if dragging then
				offset = math.max(offset - math.round(delta.X), 0)
				update()
			end

			if cursorDragging then
				cursorPosUpdate(inputObject)
			end
		end
	end)

	backgroundFrame.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton3 then
			dragging = false
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			cursorDragging = false
		end
	end)

	backgroundFrame.MouseWheelForward:Connect(function()
		zoom = math.max(zoom - 1, 5)
		update()
	end)

	backgroundFrame.MouseWheelBackward:Connect(function()
		zoom = math.min(zoom + 1, 31)
		update()
	end)

	return backgroundFrame
end