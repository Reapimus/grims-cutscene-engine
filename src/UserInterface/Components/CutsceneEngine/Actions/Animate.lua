return function(action)
	assert(action.Target and action.Target:IsA"Humanoid", "Animate requires a valid target.")

	local animTrack = script:FindFirstChild(action.AnimationId)
	if animTrack == nil then
		animTrack = Instance.new("Animation")
		animTrack.AnimationId = "rbxassetid://"..action.AnimationId
		animTrack.Name = action.AnimationId
		animTrack.Parent = script
	end

	action.Target:LoadAnimation(animTrack):Play()
end