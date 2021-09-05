In Grim's Cutscene Engine, an Action is a special type of keyframe that can execute a function at the specified time in the cutscene, with the specified options, and the specified target (or no target, if the action supports it)

An action can be added to the cutscene by right-clicking anywhere within the timeline and clicking on any of the "Add ___" options.

## Creating your own Actions

Want to create your own actions to use with the system? Simply create a `ModuleScript` in `CutsceneEngine.Actions` with the desired name of your action, that returns a `function` that will be fired when the action is needed, with the only argument being provided being information about the action.

The following is what the action's information looks like when this function is fired:

```lua
{
    Target; -- If this action supports specifying a target instance, this will be present
    ...; -- Any options/arguments provided to the action will be present as keys inside the table directly.
}
```

After that has been created, you then need to create a `ModuleScript` in `CutsceneEngine.ActionConfig` with the same name as you used previously, that returns a `table` containing information about how the action should be treated.

This is what the information about how an action should be treated should look like:

```lua
{
    Settings = {
		...; -- Any options you want should be specified here, with their names as their indexes and defaults as their values.
	};
	HasTarget = true or false; -- This determines whether or not this action requires a target instance (the target instance is determined by the editor as whatever instance is selected when the action is added).
}
```