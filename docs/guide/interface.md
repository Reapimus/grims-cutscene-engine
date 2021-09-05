The interface of Grim's Cutscene Engine's editor is heavily inspired by/based off of another Roblox plugin which came close to the type of system I was looking for, which said plugin is [TweenSequence Editor](https://devforum.roblox.com/t/tweensequence-editor/218976).

## Getting Started

When you first open the editor in a place file where the engine is not present or the editor has never been used before, it will prompt you to create a new cutscene before you can do anything else.

Any cutscenes saved in `ReplicatedStorage.ExportedCutscenes` are able to be edited by the engine.

## Navigating the Editor

### The Topbar

The buttons across the top of the main editor window are as follows, from left to right:

* **Save**
    \- Clicking this will save any changes you have made to the cutscene, and automatically select the exported cutscene in the explorer.
* **Preview**
    \- Clicking this will preview the currently loaded cutscene in the editor.
* **Reload**
    \- Clicking this will reload the current cutscene from its last saved information.
* **Current Cutscene**
    \- Clicking this will bring up a list of cutscenes you can load.
* **Rename**
    \- Clicking this will prompt you to rename the cutscene you have currently loaded.
* **Delete**
    \- Clicking this will delete the cutscene you currently have loaded.
* **EasingStyle**
    \- If a keyframe is selected, this will let you choose the EasingStyle for the keyframe.
* **EasingDirection**
    \- If a keyframe is selected, this will let you choose the EasingDirection for the keyframe.
* **Capture Camera CFrame**
    \- Clicking this will capture the camera's current CFrame as a keyframe for the camera, this is the only way to animate the camera as it would likely be really difficult to use if the camera was always being tracked like other properties.
* **Setup Joints**
    \- If you have a Motor6D selected, clicking this will automatically add their C0 and C1 as properties that are being tracked for this cutscene.

### The Explorer

To the left side of the editor window is the Explorer. This shows all instances that have properties that are being tracked.

* Scroll up and down when the mouse is within this widget to scroll through the displayed instances and properties, if you can't see them all at once.

To **add a new tracked property to an instance**, click the plus button to the right of the instance's name in the explorer. You will then be prompted to enter the name of a property to track. When the property is added its initial value is set to whatever its value currently is in studio.

***While the editor is active, it will listen for changes to tracked properties.*** Any changes will either add a new keyframe or modify a keyframe if one already exists for the property at the playhead's current position.

To **delete a tracked property**, click the trash button to the right of the property's name in the explorer. This will also erase all of the properties keyframes.

### The Timeline

To the right side of the editor window, is the Timeline. this shows all the keyframes and actions in the cutscene, and can be used to view them and move them around.

* Left click or drag the mouse to move the playhead’s position.
* Scroll up and down when the mouse is inside the Timeline to zoom in and out.
* Drag with the middle mouse button to move left and right.

As you move the playhead, the animation will adjust to appear as how it would look at that moment in time when the cutscene is playing in-game.

#### Manipulating a Keyframe

* Select a keyframe by clicking on it.
* Move a keyframe by dragging it with the mouse. You can’t move a keyframe onto another keyframe, and you can’t move keyframes with a time of 0.
* Copy and paste a keyframe’s data, or delete a keyframe, by right clicking on a keyframe and selecting the appropriate action.

!!! caution
    When using a cutscene in-game, make sure that everything the cutscene uses is *exactly where it should be*, otherwise that cutscene will not work!