local themeHandler = require(script.Parent.Parent.Services.ThemeHandler)
local propertyWatcher = require(script.Parent.PropertyWatcher)
local stateHandler = require(script.Parent.StateHandler)
local propertyItem = require(script.Parent.PropertyItem)
local keyframe = require(script.Parent.Keyframe)

local function isValidProperty(prop)
	local valType = typeof(prop)
	return valType == "number" or
		valType == "bool" or
		valType == "CFrame" or
		valType == "Vector3" or
		valType == "Vector3int16" or
		valType == "Vector2" or
		valType == "Rect" or
		valType == "Color3" or
		valType == "UDim" or
		valType == "UDim2" or
		valType == "UDim2"
end

return function(instance)
	local window = Instance.new("ImageButton")
	window.Name = "AddProperty"
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
	inputBox.PlaceholderText = "Enter Property Name"
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
			local cutsceneData = stateHandler.LoadedCutsceneData
			local prop = inputBox.Text
			window:Destroy()

			local value
			if not pcall(function()
					value = instance[prop]
				end) then
				warn(string.format("%s is not a property of %s.", prop, tostring(instance)))
				return
			end

			if not isValidProperty(value) then
				warn(isValidProperty(value), string.format("%s cannot be animated using TweenService.", prop))
				return
			end

			if prop == "CFrame" and instance:IsA"Camera" then
				warn("This property can only be used via the snapshot button!")
				return
			end

			if cutsceneData.Keyframes[instance] == nil then
				cutsceneData.Keyframes[instance] = {}
			else
				if cutsceneData.Keyframes[instance][prop] then
					warn("Property is already added")
					return
				end
			end

			cutsceneData.Keyframes[instance][prop] = {
				InitialValue = instance[prop];
				Frames = {

				};
			}

			propertyWatcher:TrackProperty(instance, prop)

			propertyItem(instance, prop).Parent = stateHandler.Explorer
			keyframe(instance, prop, 0)
		end
	end)

	return window
end