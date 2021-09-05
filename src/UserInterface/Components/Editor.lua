local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local stateHandler = require(script.Parent.StateHandler)

return function()
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "Editor"
	backgroundFrame.Position = UDim2.new(0,0,0,26)
	backgroundFrame.Size = UDim2.new(1,0,1,-26)
	backgroundFrame.BorderSizePixel = 0
	themeHandler:SyncColors(backgroundFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(backgroundFrame, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	local explorer = require(script.Parent.Explorer)()
	explorer.Parent = backgroundFrame
	stateHandler.Explorer = explorer

	local separator = Instance.new("Frame")
	separator.Position = UDim2.new(0,250,0,0)
	separator.Size = UDim2.new(0,2,1,0)
	separator.BorderSizePixel = 0
	separator.ZIndex = 1
	separator.Parent = backgroundFrame
	themeHandler:SyncColors(separator, "BackgroundColor3", Enum.StudioStyleGuideColor.Border)

	local timeline = require(script.Parent.Timeline)()
	timeline.Parent = backgroundFrame
	stateHandler.Timeline = timeline

	return backgroundFrame
end