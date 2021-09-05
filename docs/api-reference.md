## Classes

### CutsceneHandler

```lua
CutsceneEngine.new(cutsceneData) -> CutsceneHandler
```

The main class that handles all cutscene data and how it is played.

#### CutsceneHandler.Playing

A value that can be used to determine whether or not the cutscene is playing.

#### CutsceneHandler.Paused

A value that can be used to determine whether or not the cutscene is paused.

#### CutsceneHandler:Play()

```lua
CutsceneHandler:Play()
```

A method to play the cutscene.

#### CutsceneHandler:Stop()

```lua
CutsceneHandler:Stop()
```

A method to stop the cutscene from playing.

#### CutsceneHandler:Pause()

```lua
CutsceneHandler:Pause()
```

A method to pause the cutscene if it was playing.

#### CutsceneHandler:Resume()

```lua
CutsceneHandler:Resume()
```

A method to resume playback of the cutscene if it was paused.