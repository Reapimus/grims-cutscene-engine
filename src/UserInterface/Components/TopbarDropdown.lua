local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)

return function(title, options)
	local newButton = Instance.new("TextButton")
	newButton.BorderSizePixel = 1
	newButton.Size = UDim2.new(0,140,0,21)
	newButton.Position = UDim2.new(0,0,0,0)
	newButton.TextSize = 6
	newButton.TextWrapped = true
	newButton.TextTruncate = Enum.TextTruncate.AtEnd
	newButton.TextXAlignment = Enum.TextXAlignment.Left
	themeHandler:SyncColors(newButton, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(newButton, "TextColor3", Enum.StudioStyleGuideColor.MainText)
	themeHandler:SyncColors(newButton, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	local frame = Instance.new("ScrollingFrame")
	frame.Position = UDim2.new(0,0,1,0)
	frame.BorderSizePixel = 1
	frame.CanvasSize = UDim2.new()
	frame.ScrollBarThickness = 6
	frame.Visible = false
	frame.ZIndex = 9999
	frame.Parent = newButton
	themeHandler:SyncColors(frame, "ScrollBarImageColor3", Enum.StudioStyleGuideColor.ScrollBar)
	themeHandler:SyncColors(frame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(frame, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = frame

	local changedEvent = Instance.new("BindableEvent")

	newButton.MouseButton1Down:Connect(function()
		frame.Visible = not frame.Visible
	end)

	local API = {}
	local proxy = {}
	setmetatable(proxy, {
		__index = function(t, i)
			return API[i] or newButton[i]
		end;

		__newindex = function(t, i, v)
			if API[i] then
				API[i] = v
			else
				newButton[i] = v
			end
		end;

		__tostring = function()
			return tostring(newButton)
		end
	})

	API.OptionChosen = changedEvent.Event
	API.Current = options[1]

	function API:SetCurrent(new, fireChanged)
		API.Current = new
		newButton.Text = string.format(" %s: %s", title, API.Current)

		if fireChanged then
			changedEvent:Fire(API.Current)
		end
	end

	function API:SetOptions(new)
		for _, v in pairs(frame:GetChildren()) do
			if v:IsA"GuiButton" then
				v:Destroy()
			end
		end
		for _, v in pairs(new) do
			local button = Instance.new("TextButton")
			button.BorderSizePixel = 0
			button.Text = v
			button.Size = UDim2.new(1,0,0,21)
			button.ZIndex = 9999
			button.Parent = frame

			button.MouseButton1Down:Connect(function()
				API:SetCurrent(v, true)
				frame.Visible = false
			end)

			themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
			themeHandler:SyncColors(button, "TextColor3", Enum.StudioStyleGuideColor.MainText)
		end

		if not table.find(new, API.Current) then
			API:SetCurrent(new[1], true)
		end

		frame.Size = UDim2.new(1,0,0,math.min(#new, 4)*21)
		frame.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y)
	end

	API:SetOptions(options)
	API:SetCurrent(API.Current, true)

	return proxy
end