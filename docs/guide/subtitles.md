In Grim's Cutscene Engine, Subtitles are defined for a cutscene by specifying in the cutscene's data the `Subtitles` index as either a `ModuleScript` that returns subtitle information or a `table` that contains the subtitle information.

Subtitles do support rich text and basic markdown (italics, bold, underline, and strike-through to be precise)

## Subtitle Data Structure

A subtitle's data structure is specified as an array of dictionaries that contain information about the subtitles at a certain point in the cutscene, the start and end times of a subtitle are specified in seconds, and no two subtitles can have overlapping time ranges (if this is the case and two or more do overlap, whichever one is the first in the array is prioritized).

A subtitle's data structure could look like this:

```lua
{
    {
        StartTime = 0;
        EndTime = 3;
        Text = "This is a subtitle at the *start* of the cutscene.";
    };
    {
        StartTime = 3;
        EndTime = 5;
        Text = "And ***this*** is a subtitle at __3 seconds__ into the cutscene and ending 5 seconds into the cutscene.";
    };
}
```