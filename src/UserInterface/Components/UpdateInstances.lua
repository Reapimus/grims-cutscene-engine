-- Convenient function for previewing the cutscene in the editor without playing it
local stateHandler = require(script.Parent.StateHandler)

local function Lerp(val1, val2, alpha)
	local valType = typeof(val1)
	if valType == "bool" then
		return alpha > .5 and val2 or val1
	elseif valType == "number" then
		return val1 + ((val2 - val1) * alpha)
	else
		return val1:Lerp(val2, alpha)
	end
end

return function(time, instances, cutsceneInfo)
	stateHandler.Updating = true
	for _, v in pairs(instances) do
		local keyframeData = cutsceneInfo.Keyframes[v]
		if keyframeData then
			for name, values in pairs(keyframeData) do
				if time == 0 then
					v[name] = values.InitialValue
				else
					local lastValue = values.InitialValue
					local lastTime = 0

					for _, keyframe in pairs(values.Frames) do
						if keyframe.Time == time then
							v[name] = keyframe.Value
							break
						elseif keyframe.Time > time then
							local alpha = (time - lastTime) / (keyframe.Time - lastTime)
							v[name] = Lerp(lastValue, keyframe.Value, alpha)
							break
						else
							lastValue = keyframe.Value
							lastTime = keyframe.Time
						end
					end

					if lastTime == 0 and #values.Frames > 0 then
						local alpha = (time - lastTime) / (values.Frames[1].Time - lastTime)
						v[name] = Lerp(lastValue, values.Frames[1].Value, alpha)
					end
				end
			end
		end
	end
	stateHandler.Updating = false
end