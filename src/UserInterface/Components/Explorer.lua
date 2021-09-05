local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local stateHandler = require(script.Parent.StateHandler)
local instanceItem = require(script.Parent.InstanceItem)
local Selection = game:GetService("Selection")

return function()
	local backgroundFrame = Instance.new("ScrollingFrame")
	backgroundFrame.Name = "Explorer"
	backgroundFrame.Position = UDim2.new(0,0,0,0)
	backgroundFrame.Size = UDim2.new(0,250,1,0)
	backgroundFrame.BorderSizePixel = 0
	backgroundFrame.ScrollBarThickness = 6
	backgroundFrame.CanvasSize = UDim2.new()
	backgroundFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	backgroundFrame.ClipsDescendants = false
	backgroundFrame.ZIndex = -9998
	themeHandler:SyncColors(backgroundFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(backgroundFrame, "BorderColor3", Enum.StudioStyleGuideColor.Border)
	themeHandler:SyncColors(backgroundFrame, "ScrollBarImageColor3", Enum.StudioStyleGuideColor.ScrollBar)

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = backgroundFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0,25)
	padding.Parent = backgroundFrame

	local actionFrame = Instance.new("Frame")
	actionFrame.BackgroundTransparency = 1
	actionFrame.Size = UDim2.new(1, 0, 0, 25)
	actionFrame.Name = "__Actions"
	actionFrame.LayoutOrder = 1
	actionFrame.Parent = backgroundFrame

	local newInstancePrompt

	local function restructureExplorer()
		backgroundFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + (25*2))

		local orderedTable = {}
		local properties = {}
		for _, v in pairs(backgroundFrame:GetChildren()) do
			if v:FindFirstChild("OriginalInstance") then
				table.insert(orderedTable, v)
			elseif v:FindFirstChild"AssociatedInstance" then
				if properties[v.AssociatedInstance.Value] == nil then
					properties[v.AssociatedInstance.Value] = {}
				end
				table.insert(properties[v.AssociatedInstance.Value], v)
			end
		end

		table.sort(orderedTable, function(a,b)
			return a.Name < b.Name
		end)

		local currentIndex = 0

		for _, v in pairs(orderedTable) do
			local instance = v.OriginalInstance.Value
			currentIndex += 1
			v.LayoutOrder = currentIndex + 1
			if properties[instance] then
				table.sort(properties[instance], function(a,b)
					return a.Name < b.Name
				end)
				for _, p in pairs(properties[instance]) do
					currentIndex += 1
					p.LayoutOrder = currentIndex + 1
				end
			end
		end

		for _, v in pairs(stateHandler.Timeline:GetChildren()) do
			if v:FindFirstChild("AssociatedInstance") then
				local explorerObject
				for _, d in pairs(backgroundFrame:GetChildren()) do
					if d:FindFirstChild("AssociatedInstance") and d.AssociatedInstance.Value == v.AssociatedInstance.Value then
						if d.Property.Value == v.Property.Value then
							explorerObject = d
							break
						end
					end
				end

				if explorerObject then
					local offset = stateHandler.Timeline.Offset.Value
					local zoom = stateHandler.Timeline.Zoom.Value
					local time = v.Time.Value
					v.Visible = time >= offset and time <= offset + zoom
					v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5) -- (25*(explorerObject.LayoutOrder)+10)
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
						local offset = stateHandler.Timeline.Offset.Value
						local zoom = stateHandler.Timeline.Zoom.Value
						local time = v.Time.Value
						v.Visible = time >= offset and time <= offset + zoom
						v.Position = UDim2.new(((time-offset)/zoom), 0, 0, explorerObject.AbsolutePosition.Y - 12.5) -- (25*(explorerObject.LayoutOrder)+10)
					else
						v:Destroy()
					end
				else
					local offset = stateHandler.Timeline.Offset.Value
					local zoom = stateHandler.Timeline.Zoom.Value
					local time = v.Time.Value
					v.Visible = time >= offset and time <= offset + zoom
					v.Position = UDim2.new(((time-offset)/zoom), 0, 0, 25+10)
				end
			end
		end
	end

	backgroundFrame.ChildAdded:Connect(function(child)
		if newInstancePrompt and newInstancePrompt.Parent then
			for _, v in pairs(backgroundFrame:GetChildren()) do
				if v:FindFirstChild"AssociatedInstance" and v.AssociatedInstance.Value == newInstancePrompt.OriginalInstance.Value then
					newInstancePrompt = nil
					break
				end
			end
		end
		restructureExplorer()
		child:GetPropertyChangedSignal("Name"):Connect(restructureExplorer)
	end)

	backgroundFrame.ChildRemoved:Connect(restructureExplorer)

	local function updateSelection()
		if not stateHandler.Recording then
			return
		end
		if newInstancePrompt and not newInstancePrompt.Parent then
			newInstancePrompt = nil
		end
		if newInstancePrompt and newInstancePrompt.Parent then
			local canDelete = true
			for _, v in pairs(backgroundFrame:GetChildren()) do
				if v:FindFirstChild"AssociatedInstance" and v.AssociatedInstance.Value == newInstancePrompt.OriginalInstance.Value then
					canDelete = false
				end
			end
			if canDelete then
				newInstancePrompt:Destroy()
			end
			newInstancePrompt = nil
		end
		if #Selection:Get() > 1 then
			warn("Can only have one instance selected at once!")
		else
			local sel = Selection:Get()[1]

			for _, v in pairs(backgroundFrame:GetChildren()) do
				if v:FindFirstChild("OriginalInstance") and v.OriginalInstance.Value == sel then
					v.SelectedFrame.Visible = true
				elseif v:FindFirstChild("OriginalInstance") then
					v.SelectedFrame.Visible = false
				end
			end

			stateHandler.Topbar.SetupJoints.Visible = sel and sel:FindFirstChildWhichIsA("Motor6D", true) ~= nil

			if sel then
				if stateHandler.LoadedCutsceneData and stateHandler.LoadedCutsceneData.Keyframes then
					if stateHandler.LoadedCutsceneData.Keyframes[sel] == nil then
						newInstancePrompt = instanceItem(sel)
						newInstancePrompt.SelectedFrame.Visible = true
						newInstancePrompt.Parent = backgroundFrame
					end
				end
			end
		end
	end

	Selection.SelectionChanged:Connect(updateSelection)

	return backgroundFrame
end