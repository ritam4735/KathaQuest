using System;
using System.Collections.Generic;

/// <summary>
/// Pure C# serializable class — saved to disk as JSON.
/// Never add Unity types (GameObject etc.) here.
/// </summary>
[Serializable]
public class SaveData
{
    public int childAge = 7;

    // storyId -> data
    public List<StoryProgress> stories = new List<StoryProgress>();

    // unlocked stickers (IDs like "Sticker_Tortoise")
    public List<string> stickers = new List<string>();

    public StoryProgress GetStory(string storyId)
    {
        return stories.Find(s => s.storyId == storyId);
    }

    public StoryProgress GetOrCreateStory(string storyId)
    {
        var p = GetStory(storyId);
        if (p == null)
        {
            p = new StoryProgress { storyId = storyId };
            stories.Add(p);
        }
        return p;
    }
}

[Serializable]
public class StoryProgress
{
    public string storyId;
    public bool completed;
    public int starsEarned;
    public int lastStepIndex;      // resume position
    public List<string> badges = new List<string>();
}
