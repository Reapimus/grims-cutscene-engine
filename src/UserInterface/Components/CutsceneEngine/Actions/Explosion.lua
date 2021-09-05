return function(action)
	assert(action.Target and (action.Target:IsA"BasePart" or action.Target:IsA"Attachment"), "Explosion requires a valid target.")

	local ex = Instance.new("Explosion")
	ex.BlastPressure = 0
	ex.BlastRadius = action.BlastRadius or 4
	ex.Position = action.Target:IsA"Attachment" and action.Target.WorldPosition or action.Target.Position
	ex.ExplosionType = Enum.ExplosionType.NoCraters
	ex.Parent = workspace
	game:GetService("Debris"):AddItem(ex, 5)
end