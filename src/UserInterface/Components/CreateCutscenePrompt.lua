local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local stateHandler = require(script.Parent.StateHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function()
	stateHandler.Topbar.Parent.Visible = false

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.ZIndex = 999999
	themeHandler:SyncColors(backgroundFrame, "BackgroundColor3", Enum.StudioStyleGuideColor.MainBackground)

	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.new(1, 0, 0, 30)
	text.AnchorPoint = Vector2.new(0, .5)
	text.Position = UDim2.new(0, 0, .5, -35)
	text.TextSize = 14
	text.Text = "Create new cutscene"
	text.Parent = backgroundFrame
	themeHandler:SyncColors(text, "TextColor3", Enum.StudioStyleGuideColor.MainText)

	local button = Instance.new("TextButton")
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0, 100, 0, 25)
	button.AnchorPoint = Vector2.new(.5, .5)
	button.Position = UDim2.new(.5, 0, .5, 0)
	button.TextSize = 12
	button.Text = "Create"
	button.Parent = backgroundFrame
	themeHandler:SyncColors(button, "BackgroundColor3", Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected)
	themeHandler:SyncColors(button, "TextColor3", Enum.StudioStyleGuideColor.MainText)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = button

	button.MouseButton1Down:Connect(function()
		stateHandler.Topbar.Parent.Visible = true
		backgroundFrame:Destroy()
		stateHandler:NewCutscene()
	end)

	return backgroundFrame
end