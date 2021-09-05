local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)

return function(title)
	local newButton = Instance.new("TextBox")
	newButton.Name = title
	newButton.BorderSizePixel = 1
	newButton.Size = UDim2.new(0,100,0,11)
	newButton.Position = UDim2.new(0,0,0,0)
	newButton.TextSize = 6
	newButton.TextWrapped = true
	newButton.TextTruncate = Enum.TextTruncate.AtEnd
	newButton.TextXAlignment = Enum.TextXAlignment.Left
	newButton.ClearTextOnFocus = false
	themeHandler:SyncColors(newButton, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(newButton, "TextColor3", Enum.StudioStyleGuideColor.MainText)
	themeHandler:SyncColors(newButton, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = title
	label.Size = UDim2.new(1,0,0,10)
	label.AnchorPoint = Vector2.new(0,1)
	label.TextSize = 6
	label.Parent = newButton
	themeHandler:SyncColors(label, "TextColor3", Enum.StudioStyleGuideColor.MainText)

	return newButton
end