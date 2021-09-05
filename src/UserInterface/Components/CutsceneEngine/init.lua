--[[
CUTSCENE ENGINE DOCUMENTATION

CutsceneEngine.new(module)
	- This will create a new cutscene handler using the provided module or cutscene data (cutscene data would be the table that the engine exports into a module in ReplicatedStorage.ExportedCutscenes)

-- Cutscene Handler

---- Properties
boolean CutsceneHandler.Playing
	- A value that can be used to determine whether or not the cutscene is playing (I advise you don't directly set this)

boolean CutsceneHandler.Paused
	- A value that can be used to determine whether or not the cutscene is paused (I also advise against setting this directly)

table CutsceneHandler.CutsceneData
	- The cutscene data that was provided to this handler (I would also advise against modifying this)

---- Events
event CutsceneHandler.DonePlaying
	- An event that gets fired when the cutscene finishes playing

---- Functions
function CutsceneHandler:Play()
	- Plays the cutscene

function CutsceneHandler:Stop()
	- Stops the cutscene

function CutsceneHandler:Resume()
	- Resumes the cutscene if it was paused

function CutsceneHandler:Pause()
	- Pauses the cutscene if it was playing

--]]

local constructor = {}
local cutscenePlayer = {}
cutscenePlayer.__index = cutscenePlayer

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

assert(RunService:IsClient() or RunService:IsStudio(), "CutsceneEngine can only be used from the client!")

local IsEdit do
	local success = pcall(function()
		IsEdit = RunService:IsEdit()
	end)

	if not success then
		IsEdit = false
	end
end

local SubtitleEngine = require(script.SubtitleEngine)

function constructor:SetSubtitleAppearance(options: {})
	SubtitleEngine:SetSubtitleAppearance(options)
end

function constructor:SetSubtitlesEnabled(state: boolean)
	SubtitleEngine:SetSubtitlesEnabled(state)
end

function constructor.new(module: table | ModuleScript): {}
	assert(typeof(module) == "Instance" and module:IsA"ModuleScript" or type(module) == "table", string.format("CutsceneEngine.new expected a ModuleScript or Table, got %s instead", typeof(module)))
	if typeof(module) == "Instance" then
		module = require(module)
	end

	local newClass = {}
	setmetatable(newClass, cutscenePlayer)

	newClass.CutsceneData = module
	newClass.__DonePlayingEvent = Instance.new("BindableEvent")
	newClass.DonePlaying = newClass.__DonePlayingEvent.Event

	newClass.Playing = false
	newClass.Paused = false
	newClass.__Tweens = {}

	if newClass.CutsceneData.Subtitles then
		local subtitles = newClass.CutsceneData.Subtitles
		if typeof(subtitles) == "Instance" then
			subtitles = require(subtitles)
		end
		newClass.__Subtitles = subtitles
	else
		newClass.__Subtitles = nil
	end

	-- Build all the tweens
	for v, properties in pairs(newClass.CutsceneData.Keyframes) do
		for prop, values in pairs(properties) do
			local lastTime = 0
			for _, keyframe in pairs(values.Frames) do
				local tweenInfo = TweenInfo.new(keyframe.Time - lastTime, keyframe.EasingStyle, keyframe.EasingDirection, 0, false, 0)
				local propTable = {
					[prop] = keyframe.Value;
				}
				local tween = TweenService:Create(v, tweenInfo, propTable)
				table.insert(newClass.__Tweens, {
					Tween = tween;
					DelayTime = lastTime;
				})
				lastTime = keyframe.Time
			end
		end
	end

	return newClass
end

function cutscenePlayer:ResetValues()
	workspace.CurrentCamera.CameraType = IsEdit and Enum.CameraType.Fixed or Enum.CameraType.Custom
	for v, properties in pairs(self.CutsceneData.Keyframes) do
		for prop, values in pairs(properties) do
			v[prop] = values.InitialValue
		end
	end
end

function cutscenePlayer:StopTweens()
	self.Running = false
	self.Paused = false
	self.__TimeIntoCutscene = nil
	SubtitleEngine:SetText()
	for _, props in pairs(self.__Tweens) do
		props.Tween:Cancel()
	end
end

function cutscenePlayer:PauseTweens()
	self.Paused = true
	SubtitleEngine:SetText()
	for _, props in pairs(self.__Tweens) do
		if props.Tween.PlaybackState == Enum.PlaybackState.Playing then
			props.Tween:Pause()
		end
	end
end

function cutscenePlayer:ResumeTweens()
	self.Paused = false
	for _, props in pairs(self.__Tweens) do
		if props.Tween.PlaybackState == Enum.PlaybackState.Paused then
			props.Tween:Play()
		end
	end
end

function cutscenePlayer:Pause()
	if self.Paused or not self.Running then
		return
	end
	self:PauseTweens()
end

function cutscenePlayer:Resume()
	if not self.Paused or not self.Running then
		return
	end
	self:ResumeTweens()
end

function cutscenePlayer:Play()
	self.__TimeIntoCutscene = nil
	self:ResetValues()
	if self.Running then
		self:StopTweens()
	end
	self.Paused = false
	self.Running = true

	if self.CutsceneData.Keyframes[workspace.CurrentCamera] then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	end

	local currentSubtitle = ""

	local delayedActions = {}
	if self.CutsceneData.Actions then
		for _, action in pairs(self.CutsceneData.Actions) do
			local Time = action.Time
			local Func = require(script.Actions:FindFirstChild(action.Name))
			if Time == 0 then
				Func(action)
			else
				table.insert(delayedActions, {
					Func = Func;
					Action = action;
					Time = Time;
					Completed = false;
				})
			end
		end
	end

	local delayedTweens = {}
	for _, props in pairs(self.__Tweens) do
		local tween = props.Tween
		local delayTime = props.DelayTime
		if delayTime == 0 then
			tween:Play()
		else
			table.insert(delayedTweens, {
				Tween = tween;
				DelayTime = delayTime;
				Playing = false;
			})
		end
	end

	local heartbeatConnection
	local start = os.clock()
	local tweensDone = false
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock() - start
		if self.Paused then
			if self.__TimeIntoCutscene == nil then
				self.__TimeIntoCutscene = now
			end
			return
		else
			if self.__TimeIntoCutscene then
				start = os.clock() - self.__TimeIntoCutscene
				now = self.__TimeIntoCutscene
				self.__TimeIntoCutscene = nil
			end
		end
		if not self.Running then
			self.Running = false
			heartbeatConnection:Disconnect()
			return
		end
		if tweensDone then
			local allDone = true
			for _, props in pairs(self.__Tweens) do
				local tween = props.Tween
				if tween.PlaybackState == Enum.PlaybackState.Playing then
					allDone = false
				end
			end
			if allDone then
				self.Running = false
				SubtitleEngine:SetText()
				heartbeatConnection:Disconnect()
				self:ResetValues()
				return
			end
		else
			local allPlaying = true
			if self.__Subtitles then
				local chosenSubtitle
				for _, subtitle in pairs(self.__Subtitles) do
					if now > subtitle.StartTime and now <= subtitle.EndTime then
						chosenSubtitle = subtitle.Text
					end
				end

				if currentSubtitle ~= chosenSubtitle then
					currentSubtitle = chosenSubtitle
					SubtitleEngine:SetText(chosenSubtitle)
				end
			end
			for _, action in pairs(delayedActions) do
				if not action.Completed then
					if now > action.Time then
						action.Completed = true
						action.Func(action.Action)
					else
						allPlaying = false
					end
				end
			end
			for _, props in pairs(delayedTweens) do
				if not props.Playing then
					if now > props.DelayTime then
						props.Playing = true
						props.Tween:Play()
					else
						allPlaying = false
					end
				end
			end
			tweensDone = allPlaying
		end
	end)
end

function cutscenePlayer:Stop()
	self:StopTweens()
	self:ResetValues()
end

return constructor
