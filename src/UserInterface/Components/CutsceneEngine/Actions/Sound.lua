return function(action)
	local s = Instance.new("Sound")
	s.Name = action.SoundId
	s.Volume = action.Volume or .5
	s.PlaybackSpeed = action.PlaybackSpeed or 1
	s.SoundId = action.SoundId
	s.Parent = action.Target or workspace

	s.Ended:Connect(function()
		s:Destroy()
	end)

	s:Play()
end