local module = {}
local stateHandler = require(script.Parent.StateHandler)
local keyframe = require(script.Parent.Keyframe)

local watchingProperties = {}

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

function module:StopTracking(instance, prop)
	if watchingProperties[instance] then
		if watchingProperties[instance][prop] then
			watchingProperties[instance][prop]:Disconnect()
			watchingProperties[instance][prop] = nil
		end
	end
end

function module:TrackProperty(instance, prop)
	assert(instance and prop and prop ~= "", "All arguments are required.")
	assert(instance:FindFirstChild(prop) == nil, "Property can't be added. Rename the selected instance.")

	local value
	if not pcall(function()
		value = instance[prop]
		end) then
		error(string.format("%s is not a property of %s.", prop, tostring(instance)))
	end

	assert(isValidProperty(value), string.format("%s cannot be animated using TweenService.", prop))

	local function changed()
		if not stateHandler.Recording or stateHandler.Updating or stateHandler.ResettingValues then
			return
		end
		if stateHandler.Previewing then
			return
		end
		if stateHandler.ActiveCutscenePlayer and stateHandler.ActiveCutscenePlayer.Playing then
			return
		end
		local cutsceneData = stateHandler.LoadedCutsceneData
		local time = stateHandler.Timeline.CursorPos.Value
		if time ~= 0 then
			for _, v in pairs(cutsceneData.Keyframes[instance][prop].Frames) do
				if v.Time == time/10 then
					v.Value = instance[prop]
					stateHandler:CutsceneUpdated(true)
					return
				end
			end

			table.insert(cutsceneData.Keyframes[instance][prop].Frames, {
				Time = time/10;
				Value = instance[prop];
				EasingStyle = Enum.EasingStyle.Linear;
				EasingDirection = Enum.EasingDirection.In;
			})

			keyframe(instance, prop, time)
			stateHandler:CutsceneUpdated(true)
		else
			cutsceneData.Keyframes[instance][prop].InitialValue = instance[prop]
		end
	end

	if watchingProperties[instance] then
		assert(watchingProperties[instance][prop] == nil, "Property already added.")
		watchingProperties[instance][prop] = instance:GetPropertyChangedSignal(prop):Connect(changed)
	else
		local function ancestryChanged(_, parent)
			if not parent then
				-- Cleanup the data, this object has been destroyed.
				for _, v in pairs(watchingProperties[instance]) do
					v:Disconnect()
				end
				watchingProperties[instance] = nil
			end
		end
		watchingProperties[instance] = {
			[prop] = instance:GetPropertyChangedSignal(prop):Connect(changed);
			__ancestry = instance.AncestryChanged:Connect(ancestryChanged);
		}
	end
end

function module:Clear(instance)
	if instance then
		local watches = watchingProperties[instance]
		for _, connection in pairs(watches) do
			connection:Disconnect()
		end
		watchingProperties[instance] = nil
	else
		for instance, watches in pairs(watchingProperties) do
			for _, connection in pairs(watches) do
				connection:Disconnect()
			end
			watchingProperties[instance] = nil
		end
	end
end

return module
