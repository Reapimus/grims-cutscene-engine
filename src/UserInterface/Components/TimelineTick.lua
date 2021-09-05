local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)

return function()
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(0, 3, 1, 20)
	holder.AnchorPoint = Vector2.new(.5,0)

	local line = Instance.new("Frame")
	line.Name = "Line"
	line.BorderSizePixel = 0
	line.Size = UDim2.new(1, 0, 1, -20)
	line.Position = UDim2.new(0, 0, 0, 20)
	line.Parent = holder
	themeHandler:SyncColors(line, "BackgroundColor3", Enum.StudioStyleGuideColor.Border)

	local text = Instance.new("TextLabel")
	text.Name = "Time"
	text.AnchorPoint = Vector2.new(.5,0)
	text.Position = UDim2.new(.5, 0, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = "0"
	text.Size = UDim2.new(0, 20, 0, 20)
	text.TextYAlignment = Enum.TextYAlignment.Center
	text.Parent = holder
	themeHandler:SyncColors(text, "TextColor3", Enum.StudioStyleGuideColor.MainText)

	return holder
end