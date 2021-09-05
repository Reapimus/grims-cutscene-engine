return function(action)
	assert(action.Target and action.Target:IsA"ParticleEmitter", "Emit requires a valid target.")

	action.Target:Emit(action.Rate or action.Target.Rate)
end