local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local propertyWatcher = require(script.Parent.PropertyWatcher)
local stateHandler = require(script.Parent.StateHandler)
local propertyItem = require(script.Parent.PropertyItem)
local keyframe = require(script.Parent.Keyframe)

return function()
	local window = Instance.new("ImageButton")
	window.Name = "RenameCutscene"
	window.AutoButtonColor = false
	window.Size = UDim2.new(1, 0, 1, 0)
	window.BackgroundTransparency = .5
	window.BackgroundColor3 = Color3.new(0,0,0)

	window.MouseButton1Down:Connect(function()
		window:Destroy()
	end)

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "Window"
	backgroundFrame.Size = UDim2.new(1, 0, 0, 75)
	backgroundFrame.Position = UDim2.new(0, 0, 1, -75)
	backgroundFrame.BorderSizePixel = 3
	backgroundFrame.Parent = window
	themeHandler:SyncColors(backgroundFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(backgroundFrame, "BorderColor3", Enum.StudioStyleGuideColor.Border)

	local inputBox = Instance.new("TextBox")
	inputBox.Name = "InputBox"
	inputBox.Text = ""
	inputBox.TextSize = 16
	inputBox.TextWrapped = true
	inputBox.BorderSizePixel = 2
	inputBox.Size = UDim2.new(.5, 0, 0, 40)
	inputBox.AnchorPoint = Vector2.new(0, .5)
	inputBox.Position = UDim2.new(0, 20, .5, 0)
	inputBox.PlaceholderText = "Enter Cutscene Name"
	inputBox.Parent = backgroundFrame
	themeHandler:SyncColors(inputBox, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)
	themeHandler:SyncColors(inputBox, "BorderColor3", Enum.StudioStyleGuideColor.Border)
	themeHandler:SyncColors(inputBox, "TextColor3", Enum.StudioStyleGuideColor.MainText)
	themeHandler:SyncColors(inputBox, "PlaceholderColor3", Enum.StudioStyleGuideColor.DimmedText)

	inputBox.Focused:Connect(function()
		themeHandler:SyncColors(inputBox, "BorderColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
	end)

	inputBox.FocusLost:Connect(function(en)
		themeHandler:SyncColors(inputBox, "BorderColor3", Enum.StudioStyleGuideColor.Border)

		if en then
			stateHandler:RenameCutscene(inputBox.Text)
			window:Destroy()
		end
	end)

	return window
end