local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)

return function(icon)
	local newButton = Instance.new("ImageButton")
	newButton.BorderSizePixel = 1
	newButton.Size = UDim2.new(0,21,0,21)
	newButton.Position = UDim2.new(0,0,0,0)
	newButton.Image = icon
	themeHandler:SyncColors(newButton, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(newButton, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	return newButton
end